//
//  SettingsViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires

class SettingsViewModel: ViewModel {
    let uploadedData = PublishRelay<(String, String)>()
    let sellerLocationAction = PublishRelay<Bool>()
    
    override init() {
        super.init()
        
        sellerLocationAction
            .filter{ $0 != FirebaseSession.shared.user.value?.locationActive }
            .flatMap{ result -> Single<Result<User>> in
                let user = UserUpdateModel(
                    firstName: nil,
                    lastName: nil,
                    id: nil,
                    userId: nil,
                    image: nil,
                    locationActive: result
                )
                return NetworkManager.rx.send(request: EditUserRequest(createUserModel: user), clazz: User.self)
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
                }
            }).disposed(by: disposeBag)
        
        uploadedData
            .flatMap{ result -> Single<Result<User>> in
                let image = UserImage(bucket: result.1,
                                      key: result.0)
                let user = UserUpdateModel(
                    firstName: nil,
                    lastName: nil,
                    id: nil,
                    userId: nil,
                    image: image
                )
                return NetworkManager.rx.send(request: EditUserRequest(createUserModel: user), clazz: User.self)
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
                }
            }).disposed(by: disposeBag)
    }
}
