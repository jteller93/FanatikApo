//
//  NetworkExtension.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Alamofire
import RxSwift
import RxCocoa
import Wires

extension NetworkRequest {
    convenience init(url: String, method: HTTPMethod = .get) {
        self.init(url: url, method: method, headers: NetworkConfiguration.defaultHeaders())
    }
}

extension NetworkManager {
    
    @discardableResult
    static func download(url: String, completion: @escaping (_ error: Error?, _ destination: URL?) -> Void) -> DownloadRequest {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        return Alamofire.download(url, to: destination).downloadProgress(closure: { (progress) in
        }).responseData(completionHandler: { (response) in
            if let destinationUrl = response.destinationURL {
                completion(nil, destinationUrl)
            } else {
                completion(response.error, nil)
            }
        })
    }
    
    struct rx {
        static func download(url: String) -> Single<URL> {
            return Single.create(subscribe: { (single) -> Disposable in
                let request = NetworkManager.download(url: url, completion: { (error, url) in
                    if (error != nil) {
                        single(.error(error!))
                    } else if (url != nil) {
                        single(.success(url!))
                    } else {
                        single(.error(NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                    }
                })
                return Disposables.create {
                    request.cancel()
                }
            })
        }
        
        static func send<T: Mappable>(request: NetworkRequest, clazz: T.Type) -> Single<T> {
            return Single.create(subscribe: { (single) -> Disposable in
                let networkRequest = NetworkManager.send(request: request, clazz: clazz, completion: { (data, error) in
                    if (error != nil) {
                        single(.error(error!.networkingError!))
                    } else if (data != nil) {
                        single(.success(data!))
                    } else {
                        single(.error   (NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                    }
                })
                return Disposables.create {
                    networkRequest?.cancel()
                }
            })
        }
        
        static func send<T: Mappable>(request: NetworkRequest, arrayClass: Array<T>.Type) -> Single<Array<T>> {
            return Single.create(subscribe: { (single) -> Disposable in
                let networkRequest = NetworkManager.send(request: request, completion: { (data, error) in
                    if let error = error {
                        single(.error(error.networkingError!))
                    } else if let data = data {
                        do {
                            let items = try JSONDecoder().decode(arrayClass, from: data)
                            single(.success(items))
                        } catch (let e) {
                            single(.error(e))
                        }
                    } else {
                        single(.error(NSError(domain: "Invalid data", code: -1, userInfo: nil)))
                    }
                })
                return Disposables.create {
                    networkRequest?.cancel()
                }
            })
        }
    }
}

