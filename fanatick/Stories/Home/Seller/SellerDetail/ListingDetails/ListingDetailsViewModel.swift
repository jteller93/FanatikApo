//
//  SellerDetailsViewModel.swift
//  fanatick
//
//  Created by Yashesh on 10/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires
import Alamofire

class ListingDetailsViewModel: ViewModel {
    
    let list = BehaviorRelay<Listing?>(value: nil)
    let buyerSelected = BehaviorRelay<IndexPath?>(value: nil)
    let priceText = BehaviorRelay<String>(value: "")
    let negotiations = BehaviorRelay<[Negotiations]>(value: [])
    let listingId = BehaviorRelay<String?>(value: nil)
    let isValid             = BehaviorRelay<Bool>(value: false)
    let selectedNegotiation = BehaviorRelay<Negotiations?>(value: nil)
    let listingWithoutNegotiation = BehaviorRelay<Listing?>(value: nil)
    let startScanner = BehaviorRelay<Bool?>(value: nil)
    let qrcodeDetails = BehaviorRelay<(String?, QRCode?)>(value: (nil, nil))
    let paymentVerified = BehaviorRelay<Bool?>(value: nil)
    let cancelPayment = BehaviorRelay<Negotiations?>(value: nil)
    
    //Actions
    let selectedViewOffer = PublishRelay<IndexPath?>()
    let negotiationsAction = PublishRelay<String?>()
    let changePriceAction = PublishRelay<(String, UpdateTicketListing)>()
    let reloadList = PublishRelay<()>()
    let getBuyerDetail = PublishRelay<String>()
    let verifyPayment = PublishRelay<(String, QRCode)>()
    let cancelNegotiation = PublishRelay<()>()
    
    override init() {
        super.init()
        
        negotiationsAction.flatMap { listingId -> Single<Result<[Negotiations]>> in
            return NetworkManager.rx.send(request:
                GetListingNegotiationRequest.init(listing: listingId),
                                          arrayClass: [Negotiations].self)
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
                } else if let values = result.value, values.count > 0 {
                    self.negotiations.accept(values)
                } else {
                    self.listingWithoutNegotiation.accept(self.list.value)
                }
            }).disposed(by: disposeBag)
        
        changePriceAction.flatMap { updatedPrice -> Single<Result<Listing>> in
            return NetworkManager.rx.send(request: UpdateTicketPriceRequest.init(listing: updatedPrice.0, ticketPriceModel: updatedPrice.1), clazz: Listing.self)
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
                    self.list.accept(values)
                    self.reloadList.accept(())
                } else {
                    self.list.accept(nil)
                }
            }).disposed(by: disposeBag)
        
        getBuyerDetail.flatMap { userID -> Single<Result<User>> in
            return NetworkManager.rx.send(request: GetUsersDetails.init(user: userID), clazz: User.self)
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
                    var negotiation = self.selectedNegotiation.value
                    negotiation?.buyer = values
                    self.selectedNegotiation.accept(negotiation)
                }
            }).disposed(by: disposeBag)
        
        verifyPayment.flatMap { qrcode -> Single<Result<Listing>> in
            return NetworkManager.rx.send(request: VerifyPayment.init(transaction: qrcode.0, qrCode: qrcode.1), clazz: Listing.self)
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
                } else {
                    self.paymentVerified.accept(true)
                }
            }).disposed(by: disposeBag)
        
        cancelNegotiation.flatMap { _ -> Single<Result<Negotiations>> in
            return NetworkManager.rx.send(request:
                CancelNegotiation.init(negotiation: self.selectedNegotiation.value?.id ?? ""),
                                          clazz: Negotiations.self)
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
                    self.cancelPayment.accept(values)
                }
            }).disposed(by: disposeBag)
        
    }
    
}
