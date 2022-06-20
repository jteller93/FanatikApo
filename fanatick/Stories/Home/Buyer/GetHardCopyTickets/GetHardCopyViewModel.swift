//
//  GetHardCopyViewModel.swift
//  fanatick
//
//  Created by Yashesh on 04/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import Wires

class GetHardCopyViewModel: ViewModel {

    let listing = BehaviorRelay<Listing?>(value: nil)
    let location = BehaviorRelay<UserLocation?>(value: nil)
    let userId = BehaviorRelay<String>(value: "")
    let phoneNumber = BehaviorRelay<SellerPhoneNumber?>(value: nil)
    let transactions = BehaviorRelay<Transaction?>(value: nil)
    
    let sellerLocationAction = PublishRelay<String>()
    let getSellerCallNumber = PublishRelay<String>()
    let listingAction = PublishRelay<String>()
    
    override init() {
        super.init()
        
        listing.map{$0?.transaction?.id}
            .filter{ $0 != nil }
            .flatMap{ NetworkManager.rx.send(request: TransactionGetRequest(transaction: $0!!), clazz: Transaction.self) }
            .subscribe(onNext: { [weak self] (transaction) in
                self?.transactions.accept(transaction)
                }, onError: { (_) in
            }).disposed(by: disposeBag)
        
        sellerLocationAction.flatMap { userID -> Single<Result<UserLocation>> in
            return NetworkManager.rx.send(request:
                GetSellerLocation.init(user: userID),
                                          clazz: UserLocation.self)
                .toResult()
                .do(onSuccess: { _ in
                    ActivityIndicator.shared.stop()
                }, onSubscribe: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext:{ [weak self] (result) in
                guard let `self` = self else { return }
                
                if let error = result.error {
                    self.error.accept(error.runtimeError)
                } else if let values = result.value {
                    self.location.accept(values)
                }
            }).disposed(by: disposeBag)
        
        getSellerCallNumber.flatMap { transacitonId -> Single<Result<SellerPhoneNumber>> in
            return NetworkManager.rx.send(request:
                GetPhoneNumber.init(transaction: transacitonId),
                                          clazz: SellerPhoneNumber.self)
                .toResult()
                .do(onSuccess: { _ in
                    ActivityIndicator.shared.stop()
                }, onSubscribe: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext:{ [weak self] (result) in
                guard let `self` = self else { return }
                
                if let error = result.error {
                    self.error.accept(error.runtimeError)
                } else if let values = result.value {
                    self.phoneNumber.accept(values)
                }
            }).disposed(by: disposeBag)
    }
}
