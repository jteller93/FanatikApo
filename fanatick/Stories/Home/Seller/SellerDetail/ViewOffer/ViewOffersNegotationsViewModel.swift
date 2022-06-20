//
//  ViewOfferNegotationsViewModel.swift
//  fanatick
//
//  Created by Yashesh on 21/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires
import Alamofire

class ViewOffersNegotationsViewModel: ViewModel {
    let negotiationsChanged = BehaviorRelay<Bool>(value: false)

    let list = BehaviorRelay<Listing?>(value: nil)
    let selectedNegotiation = BehaviorRelay<Negotiations?>(value: nil)
    let selectedListing = BehaviorRelay<Listing?>(value: nil)
    let negotiationsID = BehaviorRelay<String?>(value: nil)
    let events = BehaviorRelay<[NegotiationsEvents]>(value: [])
    let priceText = BehaviorRelay<String>(value: "")
    let isValid = BehaviorRelay<Bool>(value: false)
    let isAccept = BehaviorRelay<Bool>(value: false)
    let listingID = BehaviorRelay<String>(value: "")
    let completedTransaction = BehaviorRelay<Transaction?>(value: nil)
    let transactionCanceled = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String??>(value: nil)
    
    //Actions
    let negotiationsEvent = PublishRelay<String>()
    let negotationAction = PublishRelay<(String)>()
    let changePriceAction = PublishRelay<(String, NegotiationPrice)>()
    let isAcceptedAction = PublishRelay<Bool>()
    let negotiationResult = PublishRelay<Bool>()
    let listingResult = PublishRelay<Bool>()
    let negotiations = PublishRelay<String>()
    let createNegotiation = PublishRelay<StartNegotiation>()
    let buyNowTickets = PublishRelay<String>()
    let buyNowTicketsOffers = PublishRelay<String>()
    let buyNowTicketsAcceptedOffers = PublishRelay<String>()
    
    
    override init() {
        super.init()
        
        negotiationsEvent.flatMap { negotiationsID -> Single<Result<[NegotiationsEvents]>> in
            return NetworkManager.rx.send(request:
                GetNegotiationsEvents.init(negotiation: negotiationsID),
                                          arrayClass: [NegotiationsEvents].self)
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
                    self.events.accept(values)
                } else {
                    self.events.accept([])
                }
            }).disposed(by: disposeBag)
        
        changePriceAction.flatMap { updatedPrice -> Single<Result<Negotiations>> in
            return NetworkManager.rx.send(request: NegotiationAskingPrice.init(negotiation: updatedPrice.0, priceModel: updatedPrice.1), clazz: Negotiations.self)
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
                    self.negotiationsID.accept(nil)
                    self.negotiationsChanged.accept(true)
                }
            }).disposed(by: disposeBag)

        
        negotationAction.flatMap { negotiationsAction -> Single<Result<Negotiations>> in
            let request = NegotiationAction.init(negotiation: negotiationsAction, accept: self.isAccept.value)
            return NetworkManager.rx.send(request: request, clazz: Negotiations.self)
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
                    self.negotiationResult.accept(self.isAccept.value)
                }
            }).disposed(by: disposeBag)
        
        negotiations.flatMap { listID -> Single<Result<[Listing]>> in
            return NetworkManager.rx.send(request:
                
                GetListingRequest.init(id: listID),
                                          arrayClass: [Listing].self)
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
                    self.listingResult.accept(self.isAccept.value)
                }
            }).disposed(by: disposeBag)
        
        negotiations.flatMap { listID -> Single<Result<[Negotiations]>> in
            return NetworkManager.rx.send(request:
                GetListingNegotiationRequest.init(listing: listID),
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
                    if let negotiation = values.first {
                        self.selectedNegotiation.accept(negotiation)
                        
                        var list = self.list.value
                        list?.transaction = negotiation.transaction
                        self.list.accept(list)
                    }
                } else {
                    self.selectedNegotiation.accept(nil)
                }
            }).disposed(by: disposeBag)

        createNegotiation.flatMap { negotiation -> Single<Result<Negotiations>> in
            return NetworkManager.rx.send(request:
                CreateNegotiation.init(negotiation: negotiation),
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
                } else if let value = result.value {
                    self.negotiationsID.accept(value.id)
                    self.negotiationsChanged.accept(true)
                }
            }).disposed(by: disposeBag)
        
        buyNowTickets.flatMap { token -> Single<Result<Transaction>> in
            return NetworkManager.rx.send(request:
                CreateTransaction.init(listing: self.list.value?.id ?? "", token: StripeToken(token: token)),
                                          clazz: Transaction.self)
                .toResult()
                .do(onSuccess: { _ in
                    ActivityIndicator.shared.stop()
                }, onSubscribe: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext:{ [weak self] (result) in
                guard let `self` = self else { return }
                
                if let error = result.error {
                    self.errorMessage.accept(error.localizedDescription)
                    self.error.accept(error.runtimeError)
                } else if let value = result.value {
                    self.completedTransaction.accept(value)
                }
            }).disposed(by: disposeBag)
        
        buyNowTicketsOffers.flatMap { token -> Single<Result<Negotiations>> in
            var request:NetworkRequest
            if (self.selectedNegotiation.value?.status == .accepted) {
                request = GetNegotiation.init(negotiation: self.selectedNegotiation.value!.id!)
            } else {
                request = NegotiationAction.init(negotiation: self.selectedNegotiation.value!.id!, accept: true)
            }
            
            return NetworkManager.rx.send(request: request, clazz: Negotiations.self)
                .toResult()
                .do(onSuccess: { (result) in
                    self.selectedNegotiation.accept(result.value)
                    self.buyNowTicketsAcceptedOffers.accept(token)
                }, onError:  { (error) in
                    self.errorMessage.accept(error.localizedDescription)
                })
        }.subscribe(onNext:{ [weak self] (result) in
            guard let `self` = self else { return }
            
            if let error = result.error {
                self.error.accept(error.runtimeError)
            }
        }).disposed(by: disposeBag)
        
        
        buyNowTicketsAcceptedOffers.flatMap { token -> Single<Result<Transaction>> in
            return NetworkManager.rx.send(request:
                CreatePayment.init(transaction: self.selectedNegotiation.value?.transaction?.id ?? "", token: StripeToken(token: token)),
                                          clazz: Transaction.self)
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
                } else if let value = result.value {
                    self.completedTransaction.accept(value)
                }
            }).disposed(by: disposeBag)
    }
}
    
