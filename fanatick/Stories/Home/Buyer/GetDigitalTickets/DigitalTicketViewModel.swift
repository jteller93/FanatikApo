//
//  DigitalTicketViewModel.swift
//  fanatick
//
//  Created by Yashesh on 01/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Wires
import Alamofire

class DigitalTicketViewModel: ViewModel {
    
    var digitalTickets = [Any]()
    var tickets = BehaviorRelay<[DigitalTicket]>(value: [])
    let listing = BehaviorRelay<Listing?>(value: nil)
    let downloadedTickets = BehaviorRelay<[Any]?>(value: nil)
    let downloadComplete = BehaviorRelay<Bool?>(value: nil)
    let transactions = BehaviorRelay<Transaction?>(value: nil)
    
    //Actions
    let downloadTickets = PublishRelay<String>()
    
    override init() {
        super.init()
        
        listing.map{$0?.transaction?.id}
        .filter{ $0 != nil }
        .flatMap{ NetworkManager.rx.send(request: TransactionGetRequest(transaction: $0!!), clazz: Transaction.self) }
        .subscribe(onNext: { [weak self] (transaction) in
            self?.transactions.accept(transaction)
            }, onError: { (_) in
        }).disposed(by: disposeBag)
        
        downloadTickets.flatMap { listingId -> Single<Result<[DigitalTicket]>> in
            return NetworkManager.rx.send(request:
                GetDigitalTickets.init(listing: listingId),
                                          arrayClass: [DigitalTicket].self)
                .toResult()
                .do(onSuccess: { _ in
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
        
        
        tickets.subscribe(onNext:{ [weak self] tickets in
            
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
                    self?.tickets.accept(ticketsToDownload)
                } else {
                    self?.downloadComplete.accept(false)
                    ActivityIndicator.shared.stop()
                }
            })
        }).disposed(by: disposeBag)
    }
}
