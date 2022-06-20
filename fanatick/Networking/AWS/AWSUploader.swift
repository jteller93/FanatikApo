//
//  AwsUploader.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/2/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import Wires
import RxCocoa
import RxSwift
import AWSS3

enum AWSImageFolder: String {
    case none
    case profile
    case ticket
}

class AWSImageUploader {
    
    static func uploadFile(folder: AWSImageFolder,
                            file: UploadFile,
                            progress: @escaping (_ progress: Double) -> Void,
                            completion: @escaping (_ key: String?, _ bucket: String?, _ error: RuntimeError?) -> Void
        ) -> AWSTask<AWSS3TransferUtilityUploadTask>? {
        let identifier = UUID().uuidString
        let bucket = AWSConfiguration.imageBucket
        let folderName = folder.rawValue
        let ext = file.ext
        var key = ""
        if folder == .none {
            key = "\(identifier).\(ext)"
        } else {
            key = "\(folderName)/\(identifier).\(ext)"
        }
        
        if let data = AWSImageUploader.getDataFrom(file: file),
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(identifier) {
            do {
                try data.write(to: path)
                
                return NetworkManager.uploadFileWithAWS(file: file, url: path, key: key, bucket: bucket, progress: { (p) in
                    progress(p)
                }) { (_, error) in
                    try? FileManager.default.removeItem(at: path)
                    completion(key, bucket, error?.runtimeError)
                }
            } catch (let error) {
                completion(nil, nil, error.runtimeError)
                return nil
            }
        } else {
            completion(nil, nil, RuntimeError.unknown)
            return nil
        }
    }
    
    static fileprivate func getDataFrom(file: UploadFile) -> Data? {
        
        switch file.type! {
        case .image:
            if file.sourceUrl == nil {
                return file.image?.jpegData(compressionQuality: 1)
            } else {
                do {
                    return try Data.init(contentsOf: file.sourceUrl!)
                } catch _ {}
            }
        case .pdf:
            do {
                return try Data.init(contentsOf: file.sourceUrl!)
            } catch _ {}
        }
        return nil
    }
}

extension AWSImageUploader {
    struct rx {
        // Return result with key and bucket
        static func uploadFile(folder: AWSImageFolder,
                                file: UploadFile) -> Observable<Result<(String, String)>> {
            return Observable.create({ (observer) -> Disposable in
                let task = AWSImageUploader.uploadFile(folder: folder, file: file, progress: { (progress) in
                    observer.onNext(Result.progress(progress))
                }, completion: { (key, bucket, error) in
                    if error == nil {
                        observer.onNext(Result.value((key ?? "", bucket ?? "")))
                        observer.onCompleted()
                    } else {
                        observer.onNext(Result.error(error!))
                        observer.onCompleted()
                    }
                })
                return Disposables.create {
                    task?.result?.cancel()
                }
            })
        }
    }
}
