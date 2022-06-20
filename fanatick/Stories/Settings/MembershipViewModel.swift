//
//  MembershipViewModel.swift
//  fanatick
//
//  Created by Essam on 1/6/20.
//  Copyright © 2020 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires

class MembershipViewModel: ViewModel {
    
    lazy var helper = IAPHelper()
    let user = FirebaseSession.shared.user

    // Action
    let subscribeAction  = PublishRelay<Void>()
    let unsubscribeAction  = PublishRelay<Void>()

    // Result
    let success = PublishRelay<Void>()
    
    override init() {
        super.init()
        
        subscribeAction.flatMap { _ -> Observable<Data> in
            ActivityIndicator.shared.start()
            self.helper.subscribe()
            return self.helper.receipt.filter({!$0.isEmpty}).take(1)
        }.flatMap {
            return NetworkManager.rx.send(request: VerifyReceipt(receiptModel: .init(receiptData: $0)), clazz: Receipt.self)
        }.flatMap {_ in
            return NetworkManager.rx.send(request: GetUserRequest(), clazz: User.self)
        }.do(onError: { [weak self] (error) in
            ActivityIndicator.shared.stop()
            guard let self = self else { return }
            self.error.accept(.runtime(error.localizedDescription))
        }).catchError{_ in Observable.empty()}
        .subscribe(onNext: { [weak self] (user) in
            self?.helper.finalizeSubscription()
            FirebaseSession.shared.user.accept(user)
            ActivityIndicator.shared.stop()
        }).disposed(by: disposeBag)
        
        unsubscribeAction.subscribe(onNext: {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }).disposed(by: disposeBag)
        
        helper.error.skip(1)
        .subscribe(onNext: { [weak self] (error) in
            ActivityIndicator.shared.stop()
            guard let self = self, let error = error, !error.isSKPaymentCanceled() else { return }
            self.error.accept(.runtime(error.localizedDescription))
        }).disposed(by: disposeBag)
    }
}
