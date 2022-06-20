//
//  EventDetailViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/6/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires
import Alamofire

class EventDetailViewModel: ViewModel {
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isEndReached = BehaviorRelay<Bool>(value: true)
    let hasNext = BehaviorRelay<Bool>(value: true)
    let cursor = BehaviorRelay<String?>(value: nil) // Cursor == nil means page 0
    let event = BehaviorRelay<Event?>(value: nil)
    let listings = BehaviorRelay<[Listing]>(value: [])
    let eventID = BehaviorRelay<String>(value: "")
    
    // MARK: Action
    let loadNextAction = PublishRelay<()>()
    let eventDetails = PublishRelay<(String)>()
    let selectedListing = PublishRelay<IndexPath>()
    
    override init() {
        super.init()
        
        loadNextAction
            .map{ [weak self] _ in return self?.event.value?.id }
            .filter{ $0 != nil }
            .flatMap { [weak self] eventId -> Single<Result<[Listing]>> in
                let cursor = self?.cursor.value
                return NetworkManager.rx.send(request:
                    GetListingsRequest(eventId: eventId ?? "",
                                       before: cursor),
                                              arrayClass: [Listing].self)
                    .toResult()
                    .do(onSuccess: { [weak self] (_) in
                        self?.isLoading.accept(false)
                        ActivityIndicator.shared.stop()
                    }, onSubscribe: { [weak self] in
                        self?.isLoading.accept(true)
                        ActivityIndicator.shared.start()
                    })
            }.subscribe(onNext: { [weak self] (result) in
                guard let `self` = self else { return }

                if let error = result.error {
                    self.error.accept(error.runtimeError)
                } else if let values = result.value, values.count > 0 {
                    var currentListing = self.listings.value
                    if self.cursor.value == nil { // First Page
                        currentListing.removeAll()
                    }
                    currentListing.append(contentsOf: values)
                    self.listings.accept(currentListing)
                    self.cursor.accept(values.last?.id)
                } else {
                    self.hasNext.accept(false)
                }
            }).disposed(by: disposeBag)
        
        event.filter{ $0 != nil }
            .map{ _ in return () }
            .bind(to: loadNextAction)
            .disposed(by: disposeBag)
        
        isEndReached
            .distinctUntilChanged()
            .map{ [weak self] isEnd -> Bool in
                guard let `self` = self else { return false}
                return isEnd && !self.isLoading.value && self.hasNext.value
            }.filter{ $0 }
            .map{ _ -> () in return () }
            .bind(to: loadNextAction)
            .disposed(by: disposeBag)
        
        //TODO: This is for hardcoded event id listing response.
//        eventDetails.flatMap { eventID -> Single<Result<[Listing]>> in
//            return NetworkManager.rx.send(request:
//                GetListingsRequest.init(eventId: eventID, before: nil),
//                                          arrayClass: [Listing].self)
//                .toResult()
//                .do(onSuccess: { _ in
//                    ActivityIndicator.shared.stop()
//                }, onSubscribe: {
//                    ActivityIndicator.shared.start()
//                })
//            }.subscribe(onNext:{ [weak self] (result) in
//                guard let `self` = self else { return }
//                
//                if let error = result.error {
//                    self.error.accept(error.runtimeError)
//                } else if let values = result.value, values.count > 0 {
//                    self.listings.accept(values)
//                } else {
//                    self.listings.accept([])
//                }
//            }).disposed(by: disposeBag)
    }
}
