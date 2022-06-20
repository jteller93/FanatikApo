//
//  AlgoliaManager.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/21/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import InstantSearchClient
import RxSwift
import Wires

class AlgoliaManager: ReactiveCompatible {
    static let shared = AlgoliaManager()
    
    #if DEBUG
    private static let appId = "05CV1OTUJQ"
    private static let apiKey = "8b5f3c2bd6d414761598ec079d27bfd9"
    private static let index = "events-dev"
    #elseif STAGING
    private static let appId = "05CV1OTUJQ"
    private static let apiKey = "8b5f3c2bd6d414761598ec079d27bfd9"
    private static let index = "events-stage"
    #else
    private static let appId = "05CV1OTUJQ"
    private static let apiKey = "8b5f3c2bd6d414761598ec079d27bfd9"
    private static let index = "events-prod"
    #endif
    
    private let client = Client(appID: AlgoliaManager.appId, apiKey: AlgoliaManager.apiKey)
    private lazy var eventIndex: Index = {
        return client.index(withName: AlgoliaManager.index)
    }()
    
    private init() {}
    
    fileprivate func search<T: Mappable>(query: Query, index: Index, completion: @escaping (T?, Error?) -> Void) -> Operation {
        return index.search(query, completionHandler: { (result, error) in
            if error != nil {
                completion(nil, error)
            } else if let result = result {
                if let response = T(dictionary: result as [String: AnyObject]) {
                    completion(response, nil)
                } else {
                    completion(nil, RuntimeError.unknown)
                }
            } else {
                completion(nil, RuntimeError.unknown)
            }
        })
    }
    
    @discardableResult
    func search(queryString: String, startDate: Date, page: Int, facet: String? = nil, completion: @escaping (AlgoliaEventResponse?, Error?) -> Void ) -> Operation {
        let filter = (facet != nil) ? "_tags:\(facet!) AND " : ""
        let query = Query(parameters: [
            "query" : queryString,
            "page" : "\(page)",
            "filters" : filter + "start_at_unix >= \(startDate.dateFor(DateForType.startOfDay).timeIntervalSince1970)",
            ])
        return search(query: query,
                      index: eventIndex,
                      completion: completion)
    }
    
    @discardableResult
    func searchFacets(completion: @escaping (AlgoliaFacetResponse?, Error?) -> Void) -> Operation {
        return eventIndex.searchForFacetValues(of: "_tags", matching: "") { (result, error) in
            if error != nil {
                completion(nil, error)
            } else if let result = result {
                if let response = AlgoliaFacetResponse(dictionary: result as [String: AnyObject]) {
                    completion(response, nil)
                } else {
                    completion(nil, RuntimeError.unknown)
                }
            } else {
                completion(nil, RuntimeError.unknown)
            }
        }
    }
}

extension Reactive where Base: AlgoliaManager {
    func search(queryString: String, startDate: Date, page: Int, facet: String? = nil) -> Single<AlgoliaEventResponse> {
        return Single.create(subscribe: { (event) -> Disposable in
            let operation = self.base.search(queryString: queryString, startDate: startDate, page: page, facet: facet, completion: { (response, error) in
                if let error = error {
                    event(.error(error))
                } else if let response = response {
                    event(.success(response))
                } else {
                    event(.error(RuntimeError.unknown))
                }
            })
            return Disposables.create {
                operation.cancel()
            }
        })
    }
    
    func searchFacets() -> Single<AlgoliaFacetResponse> {
        return Single.create(subscribe: { (event) -> Disposable in
            let operation = self.base.searchFacets( completion: { (response, error) in
                if let error = error {
                    event(.error(error))
                } else if let response = response {
                    event(.success(response))
                } else {
                    event(.error(RuntimeError.unknown))
                }
            })
            return Disposables.create {
                operation.cancel()
            }
        })
    }
}
