//
//  EditPhoneInputViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/9/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class EditPhoneInputViewModel: ViewModel {
    var phoneNumber = BehaviorRelay<String>(value: "")
    // MARK: Action
    let validateAction = PublishRelay<()>()
    
    // MARK: Result
    let success = PublishRelay<()>()
    
    override init() {
        super.init()
        
        validateAction.subscribe(onNext: { [weak self] (_) in
            self?.reauthenticate()
        }).disposed(by: disposeBag)
    }
    
    func reauthenticate() {
        NetworkManager.rx.send(request: FirebaseReauthenticationRequest(), clazz: AuthenticationResponse.self)
            .flatMap { (token) -> Single<Result<String>> in
                return FirebaseSession
                    .shared
                    .verifyUpdatePhoneNumber(firebaseToken: token.token ?? "",
                                             newPhoneNumber: StringFormatter
                                                .internalizedPhoneNumber(self.phoneNumber.value))
            }.do(onSuccess: { (_) in
                ActivityIndicator.shared.stop()
            }, onSubscribed: {
                ActivityIndicator.shared.start()
            }).subscribe(onSuccess: { [weak self] (result) in
                if let error = result.error {
                    self?.error.accept(error.runtimeError)
                } else {
                    self?.success.accept(())
                }
            }).disposed(by: disposeBag)
    }
}


