//
//  VerificationCodeViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Wires

class VerificationCodeViewModel: ViewModel {
    let verificationCode = BehaviorRelay(value: "")
    let success = PublishRelay<()>()
    let resendSuccess = PublishRelay<()>()
    let resendAction = PublishRelay<()>()
    let verifyAction = PublishRelay<()>()
    
    override init() {
        super.init()
        
        resendAction.flatMap{ _ -> Single<Result<String>> in
            let phone = FirebaseSession.shared.phoneNumber
            return FirebaseSession
                .shared
                .verifyPhoneNumber(phoneNumber: phone)
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
            FirebaseSession.shared.signInWithVerificationCode(verificationCode: self?.verificationCode.value ?? "")
                .do(onSuccess: { (_) in
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext: { [weak self] (result) in
                if result.error == nil {
                    self?.getFirebaseToken()
                } else {
                    self?.error.accept(result.error!.runtimeError)
                }
            }).disposed(by: disposeBag)
    }
    
    func getFirebaseToken() {
        FirebaseSession.shared.getToken()
            .do(onSuccess: { (_) in
                ActivityIndicator.shared.stop()
            }, onSubscribed: {
                ActivityIndicator.shared.start()
            }).subscribe(onSuccess: { [weak self] (result) in
                if result.error == nil {
                    self?.getUserDetail()
                } else {
                    self?.error.accept(result.error!.runtimeError)
                }
            }).disposed(by: disposeBag)
    }
    
    func getUserDetail() {
        let request = GetUserRequest()
        NetworkManager.rx.send(request: request, clazz: User.self)
            .do(onSuccess: { (user) in
                ActivityIndicator.shared.stop()
            }, onError: { _ in
                ActivityIndicator.shared.stop()
            }, onSubscribed: {
                ActivityIndicator.shared.start()
            }).subscribe(onSuccess: { [weak self] result in
                FirebaseSession.shared.user.accept(result)
                self?.success.accept(())
                }, onError: { [weak self] error in
                    if let error = error as? ErrorModel, error.code == "not_found" {
                        // Go to Name
                        self?.success.accept(())
                    } else {
                        self?.error.accept(error.runtimeError)
                    }
            }).disposed(by: disposeBag)
    }
}

