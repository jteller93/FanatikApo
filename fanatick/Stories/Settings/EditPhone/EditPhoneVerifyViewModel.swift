//
//  EditPhoneVerifyViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/9/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class EditPhoneVerifyViewModel: ViewModel {
    let verificationCode = BehaviorRelay(value: "")
    let success = PublishRelay<()>()
    let resendSuccess = PublishRelay<()>()
    let resendAction = PublishRelay<()>()
    let verifyAction = PublishRelay<()>()
    
    override init() {
        super.init()
        
        resendAction.flatMap{ _ -> Single<Result<String>> in
            let token = FirebaseSession.shared.updatedFirebaseToken ?? ""
            let phone = FirebaseSession.shared.updatedPhoneNumber ?? ""
            return FirebaseSession
                .shared
                .verifyUpdatePhoneNumber(firebaseToken: token, newPhoneNumber: phone)
                .do(onSuccess: { (_) in
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext: { [weak self] (result) in
                if result.error == nil {
                    self?.resendSuccess.accept(())
                } else {
                    self?.error.accept(result.error!.runtimeError)
                }
            }).disposed(by: disposeBag)
        
        verifyAction.flatMap{ [weak self] _ in
            return FirebaseSession
                .shared
                .verifyUpdatePhoneNumber(with: self?.verificationCode.value ?? "")
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

