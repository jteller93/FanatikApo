//
//  MyTicketsViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class MyTicketsViewModel: ViewModel {
    
    let selectedSegment = BehaviorRelay<Segment>(value: .openNegotiations)
    let listing = BehaviorRelay<[Listing]>(value: [])
    var digitalTickets = [Any]()
    var tickets = BehaviorRelay<[DigitalTicket]>(value: [])
    let downloadedTickets = BehaviorRelay<[Any]?>(value: nil)
    let downloadComplete = BehaviorRelay<Bool?>(value: nil)
    let selectedListing = BehaviorRelay<Listing?>(value: nil)
    let negotiations = BehaviorRelay<[Negotiations]>(value: [])
    let transactions = BehaviorRelay<[UserTransaction]>(value: [])
    let role = BehaviorRelay<Role>(value: MenuViewModel.shared.role.value)
    let viewTickets = BehaviorRelay<UserTransaction?>(value: nil)
    let viewHardcopyTickets = BehaviorRelay<UserTransaction?>(value: nil)
    let viewOffers = BehaviorRelay<UserTransaction?>(value: nil)
    let ticketsToDownlaod = BehaviorRelay<[DigitalTicket]>(value: [])
    let openNegotiations = BehaviorRelay<([OpenNegotiations],Int?)>(value: ([], nil))
    let expanded = BehaviorRelay<Int?>(value: nil)
    let openNegotiationsViewOffer = BehaviorRelay<Negotiations?>(value: nil)
    let pickupMap = BehaviorRelay<Listing?>(value: nil)
    //Actions
    let downloadTickets = PublishRelay<String>()
    let openNegotiaions = PublishRelay<()>()
    let transacitons = PublishRelay<()>()
    let expandAction = PublishRelay<(Int?)>()
    let expandActionNegotiations = PublishRelay<([OpenNegotiations])>()
    let selectedListings = PublishRelay<IndexPath>()
    
    enum Segment: Int, CaseIterable {
        case openNegotiations
        case transactions
        
        func title() -> String {
            switch self {
            case .openNegotiations:
                return LocalizedString("open_negotiations", story: .myTickets)
            case .transactions:
                return LocalizedString("transactions", story: .myTickets)
            }
        }
    }
    
    override init() {
        super.init()
        
        ticketsToDownlaod.subscribe(onNext:{ [weak self] tickets in
            
            if tickets.count == 0 {
                self?.downloadedTickets.accept(self?.digitalTickets)
                self?.downloadComplete.accept(true)
                ActivityIndicator.shared.stop()
                return
            }
            
            var ticketsToDownload = tickets
            NetworkManager.download(url: tickets.first?.ticket?.publicUrl?.absoluteString ?? "", completion: { (error, url) in
                if let destinationUrl = url {
                    self?.digitalTickets.append(destinationUrl)
                    ticketsToDownload.removeFirst()
                    self?.ticketsToDownlaod.accept(ticketsToDownload)
                } else {
                    self?.downloadComplete.accept(false)
                    ActivityIndicator.shared.stop()
                }
            })
        }).disposed(by: disposeBag)
        
        
        transacitons
            .flatMap { _ -> Single<Result<[UserTransaction]>> in
                
                return NetworkManager.rx.send(request:
                    GetTransactions.init(userType: self.role.value.value), arrayClass: [UserTransaction].self)
                    .toResult()
                    .do(onSuccess: { _ in
                        ActivityIndicator.shared.stop()
                    }, onSubscribe: {
                        ActivityIndicator.shared.start()
                    })
            }.subscribe(onNext: { [weak self] (result) in
                guard let `self` = self else { return }
                
                if let error = result.error {
                    self.error.accept(error.runtimeError)
                } else if let values = result.value {
                    let transactions = values.filter({ (transaction) -> Bool in
                        return transaction.state ?? .exception == .pickupPending
                            || transaction.state ?? .exception == .succeeded
                            || transaction.state ?? .exception == .expired
                    })
                    
                    self.transactions.accept(transactions)
                }
            }).disposed(by: disposeBag)
        
        openNegotiaions
            .flatMap { _ -> Single<Result<[OpenNegotiations]>> in
                
                return NetworkManager.rx.send(request:
                    GetNegotiations.init(userType: self.role.value.value), arrayClass: [OpenNegotiations].self)
                    .toResult()
                    .do(onSuccess: { _ in
                        ActivityIndicator.shared.stop()
                    }, onSubscribe: {
                        ActivityIndicator.shared.start()
                    })
            }.subscribe(onNext: { [weak self] (result) in
                guard let `self` = self else { return }
                
                if let error = result.error {
                    self.error.accept(error.runtimeError)
                } else if let values = result.value {
                    self.openNegotiations.accept((values, nil))
                }
            }).disposed(by: disposeBag)
        
        downloadTickets.flatMap { listingId -> Single<Result<[DigitalTicket]>> in
            return NetworkManager.rx.send(request:
                GetDigitalTickets.init(listing: listingId),
                                          arrayClass: [DigitalTicket].self)
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
                    self.digitalTickets = []
                    self.tickets.accept(values)
                } else {
                    self.tickets.accept([])
                }
            }).disposed(by: disposeBag)
    }
}
