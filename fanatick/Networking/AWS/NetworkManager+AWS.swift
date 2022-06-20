//
//  NetworkManager+AWS.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Wires
import AWSS3
import RxCocoa
import RxSwift

extension NetworkManager {
    @discardableResult
    static func uploadFileWithAWS(file: UploadFile,
                                   url: URL,
                                   key: String,
                                   bucket: String,
                                   progress: @escaping (_ progress: Double) -> Void,
                                   completion: @escaping (_ response: String?, _ error: Error?) -> Void) -> AWSTask<AWSS3TransferUtilityUploadTask> {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, awsProgress) in
            DispatchQueue.main.async {
                progress(awsProgress.fractionCompleted)
            }
        }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if error == nil {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicUrl = url?.appendingPathComponent(bucket)
                        .appendingPathComponent(key)
                    completion(publicUrl?.absoluteString, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
        
        let awsTransferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: AWSConfiguration.callbackKey)
        return awsTransferUtility!.uploadFile(url,
                                              bucket: bucket,
                                              key: key,
                                              contentType: file.type.contentType,
                                              expression: expression,
                                              completionHandler: completionHandler)
            .continueWith(block: { (task) -> Any? in
                if task.error != nil {
                    completion(nil, task.error)
                }
                return nil
            }) as! AWSTask<AWSS3TransferUtilityUploadTask>
    }
}

extension NetworkManager.rx {
    
    static func uploadFileWithAWS(file: UploadFile ,url: URL,
                                   key: String,
                                   bucket: String) -> Observable<Result<String>> {
        return Observable.create({ (observer) -> Disposable in
            let task = NetworkManager.uploadFileWithAWS(file: file, url: url, key: key, bucket: bucket, progress: { (progress) in
                observer.onNext(Result.progress(progress))
            }, completion: { (result, error) in
                if error == nil {
                    observer.onNext(Result.value(result ?? ""))
                } else {
                    observer.onNext(Result.error(error!))
                }
                observer.onCompleted()
            })
            return Disposables.create {
                task.result?.cancel()
            }
        })
    }
}

