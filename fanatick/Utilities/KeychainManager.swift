//
//  KeychainManager.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/19/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import KeychainAccess
import RxCocoa
import RxSwift

class KeychainManager {
    static let shared = KeychainManager()
    private struct Constant {
        static let service = "com.fanatick.fanatick"
    }
    private let keychain = Keychain(service: Constant.service)
    fileprivate let event = PublishSubject<String>()
    
    func setString(for key: String, value: String?) {
        keychain[string: key] = value ?? ""
        event.onNext(key)
    }
    
    func getString(for key: String) -> String? {
        return (((try? keychain.get(key)) as String??)) ?? nil
    }
}

extension Reactive where Base: KeychainManager {
    func observe(for key: String) -> Observable<String?> {
        return Observable.create({ (observer) -> Disposable in
            
            
            let disposable = self.base.event.filter{ $0 == key }
                .do(onSubscribe: {
                    observer.onNext(self.base.getString(for: key))
                }).map{ _ in self.base.getString(for: key) }
                .bind(to: observer)
            
            return Disposables.create {
                disposable.dispose()
            }
        })
    }
}

