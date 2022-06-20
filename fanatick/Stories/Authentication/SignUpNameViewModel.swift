//
//  SignUpNameViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class SignUpNameViewModel: ViewModel {
    let firstName = BehaviorRelay<String>(value: "")
    let lastName = BehaviorRelay<String>(value: "")
    let isValid = BehaviorRelay<Bool>(value: false)
    
    // Action
    let continueAction = PublishRelay<()>()
    
    // Result
    let success = PublishRelay<()>()
    
    override init() {
        super.init()
        
        Observable.combineLatest(firstName.asObservable(),
                                 lastName.asObservable()) { (firstname, lastname) in
                                    return firstname.isValidName() && lastname.isValidName()
            }.bind(to: isValid).disposed(by: disposeBag)
        
        continueAction.flatMap { [weak self] (_) -> Single<Result<User>> in
            let model = UserUpdateModel(firstName: self?.firstName.value,
                                        lastName: self?.lastName.value,
                                        id: nil,
                                        userId: nil,
                                        image: nil)
            let userRequest = CreateUserRequest(createUserModel: model)
            return NetworkManager.rx.send(request: userRequest, clazz: User.self)
                .do(onSuccess: { (_) in
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                }).toResult()
            }.subscribe(onNext: { [weak self] (result) in
                if let error = result.error?.runtimeError {
                    self?.error.accept(error)
                } else {
                    FirebaseSession.shared.user.accept(result.value)
                    self?.success.accept(())
                }
            }).disposed(by: disposeBag)
    }
}

