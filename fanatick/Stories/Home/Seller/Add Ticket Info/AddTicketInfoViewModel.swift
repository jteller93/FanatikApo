//
//  AddTicketInfoViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/10/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class AddTicketInfoViewModel: ViewModel {
    
    let event = BehaviorRelay<Event?>(value: nil)
    let ticketListing       = BehaviorRelay<Listing?>(value: nil)
    let isValid             = BehaviorRelay<Bool>(value: false)
    let ticketQty           = BehaviorRelay<String>(value: "")
    let ticketPrice         = BehaviorRelay<String>(value: "")
    let ticketMethod        = BehaviorRelay<String>(value: "")
    let sectionSelecion     = BehaviorRelay<String>(value: "")
    let rowValue            = BehaviorRelay<String>(value: "")
    let ticketIndexPath     = BehaviorRelay<IndexPath?>(value: nil)
    let pickupLocation      = BehaviorRelay<String>(value: "")
    let selectedDeliveryMethod = BehaviorRelay<DeliveryMethod?>(value: nil)
    
    //Actions
    let listingAction       = PublishRelay<Listing?>()
    let listTicketAction    = PublishRelay<()>()
    let success             = PublishRelay<()>()
    let uploadAction        = PublishRelay<(IndexPath?, (String, String)?)>()
    let reloadTable         = PublishRelay<(IndexPath?)>()
    
    func setTicketDatatoModel(listing: Listing?) {
        ticketListing.accept(listing)
    }
    
    override init() {
        super.init()
        
        Observable.combineLatest(ticketQty.asObservable(),
                                 ticketPrice.asObservable(), ticketMethod.asObservable(), pickupLocation.asObservable()) { (ticketQty, ticketPrice, ticketMethod, pickupLocation) in
                                    return ticketQty.isNotEmpty() && ticketPrice.isNotEmpty() && ticketMethod.isNotEmpty() && ((self.selectedDeliveryMethod.value ?? .digital == .hardcopy) ? pickupLocation.isNotEmpty() : true)
            }.bind(to: isValid).disposed(by: disposeBag)
        
        Observable.combineLatest(rowValue.asObservable(),
                                 sectionSelecion.asObservable()) { (rowValue, sectionSelecion) in
                                    return rowValue.isNotEmpty() && sectionSelecion.isNotEmpty() && self.checkAllSeatDataValid()
            }.bind(to: isValid).disposed(by: disposeBag)
        
        listTicketAction.flatMap { [weak self] (_) -> Single<Result<Listing>> in
            
            let ticketsModel = PostListingRequest(newListingModel: self?.ticketListing.value)
            return NetworkManager.rx.send(request: ticketsModel, clazz: Listing.self)
                .toResult()
                .do(onSuccess: { (listing) in
                    ActivityIndicator.shared.stop()
                }, onSubscribed: {
                    ActivityIndicator.shared.start()
                })
            }.subscribe(onNext: { [weak self] (result) in
                if let error = result.error?.runtimeError {
                    self?.error.accept(error)
                } else {
                    self?.success.accept(())
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func checkAllSeatDataValid() -> Bool {
        
        var isValidTickets = false
        if let listing = ticketListing.value, let tickets = listing.tickets {
            if tickets.allSatisfy({ (ticket) -> Bool in
                return ticket.seat?.isNotEmpty() ?? isValidTickets
            }), listing.row?.isNotEmpty() ?? isValidTickets, listing.section?.isNotEmpty() ?? isValidTickets {
                isValidTickets = true
            }
        }
        return isValidTickets
    }
    
    func validateSectionRowAndTickets() -> Bool {
        return checkAllSeatDataValid() && rowValue.value.isNotEmpty() && sectionSelecion.value.isNotEmpty()
    }
    
    func validDigitalTicketUploaded() -> Bool {
        var isValidTickets = false
        if let tickets = ticketListing.value?.tickets {
            if tickets.allSatisfy({ (ticket) -> Bool in
                return ticket.ticketUpload?.bucket?.isNotEmpty() ?? isValidTickets && ticket.ticketUpload?.key?.isNotEmpty() ?? isValidTickets
            }) {
                isValidTickets = true
            }
        }
        return isValidTickets
    }
}
