//
//  AuthenticationViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AuthenticationViewModel: ViewModel {
    let phoneNumber = BehaviorRelay<String>(value: "")
    // MARK: Action
    let validateAction = PublishRelay<()>()
    
    // MARK: Result
    let success = PublishRelay<()>()
    
    override init() {
        super.init()
        
        validateAction.flatMap{ [weak self] _ in
            FirebaseSession
                .shared
                .verifyPhoneNumber(phoneNumber: StringFormatter.internalizedPhoneNumber(self?.phoneNumber.value))
                .do(onSuccess: { (_) in
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext: { [weak self] (result) in
                if result.error == nil {
                    self?.success.accept(())
                } else {
                    self?.error.accept(result.error!.runtimeError)
                }
            }).disposed(by: disposeBag)
    }
}

