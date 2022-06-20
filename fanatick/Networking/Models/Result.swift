//
//  Result.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/18/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct Result<T> {
    let value: T?
    let error: Error?
    let progress: Double?
    
    static func error(_ error: Error) -> Result<T> {
        return Result(value: nil, error: error, progress: nil)
    }
    
    static func value(_ value: T) -> Result<T> {
        return Result(value: value, error: nil, progress: nil)
    }
    
    static func progress(_ progress: Double) -> Result<T> {
        return Result(value: nil, error: nil, progress: progress)
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    func toResult() -> Single<Result<Element>> {
        return Single<Result<Element>>.create { observer in
            let disposable = self.subscribe(onSuccess: { (element) in
                observer(.success(Result.value(element)))
            }, onError: { (error) in
                observer(.success(Result.error(error)))
            })
            return Disposables.create {
                disposable.dispose()
            }
        }
    }
}
