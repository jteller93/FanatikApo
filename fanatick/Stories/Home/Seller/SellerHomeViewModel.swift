//
//  SellerHomeViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/7/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires
import Alamofire

class SellerHomeViewModel: ViewModel {
    let selectedSegment = BehaviorRelay<Segment>(value: .listed)
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isEndReached = BehaviorRelay<Bool>(value: true)
    let hasNext = BehaviorRelay<Bool>(value: true)
    let cursor = BehaviorRelay<String?>(value: nil) // Cursor == nil means page 0
    let listings = BehaviorRelay<[Listing]>(value: [])
    let listingId = BehaviorRelay<String?>(value: nil)
    
    // MARK: Action
    let loadNextAction = PublishRelay<()>()
    let cellAction = PublishRelay<IndexPath>()
    let deleteAction = PublishRelay<(String)>()
    
    override init() {
        super.init()
        
        loadNextAction
            .throttle(0.2, scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Single<Result<[Listing]>> in
                let cursor = self?.cursor.value
                let segment = self?.selectedSegment.value
                var soldStatus: Bool? = nil
                var active: Bool? = nil
                if segment == .sold {
                    soldStatus = true
                } else if segment == .unsold {
                    soldStatus = false
                } else if segment == .active {
                    active = true
                    soldStatus = false
                } else {
                    soldStatus = false
                }
                
                return NetworkManager.rx.send(request:
                    GetMyListingsRequest(before: cursor,
                                         active: active,
                                         soldStatus: soldStatus),
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
                    if self.cursor.value == nil {
                        currentListing.removeAll()
                    }
                    currentListing.append(contentsOf: values)
                    
                    var ids:[String] = []
                    let listings = currentListing.filter({ (listing) -> Bool in
                        if (ids.contains(listing.id ?? "")) {
                            return false
                        } else {
                            ids.append(listing.id ?? "")
                            return true
                        }
                    })
                    
                    self.listings.accept(listings)
                    self.cursor.accept(values.last?.id)
                } else {
                    if self.cursor.value == nil { // First Page
                        self.listings.accept([])
                    }
                    self.hasNext.accept(false)
                }
            }).disposed(by: disposeBag)
        
        selectedSegment
            .skip(1)
            .do(onNext: { [weak self] (_) in
                self?.cursor.accept(nil)
                self?.hasNext.accept(true)
                self?.isLoading.accept(false)
            }).map{ _ in return () }
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
        
        deleteAction
            .flatMap { listingId -> Single<Result<DeletedList>> in
                
                return NetworkManager.rx.send(request:
                    DeleteListings.init(id: listingId), clazz: DeletedList.self)
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
                    var listings = self.listings.value
                    if let listingsId = values.code {
                        if let deletedListing = listings.firstIndex(where: { (obj) -> Bool in
                            return obj.id ?? "" == listingsId
                        }) {
                            listings.remove(at: deletedListing)
                        }
                        self.listings.accept(listings)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    enum Segment: Int, CaseIterable {
        case listed
        case active
        case sold
        case unsold
        
        func title() -> String {
            switch self {
            case .listed:
                return LocalizedString("listed", story: .home)
            case .active:
                return LocalizedString("active", story: .home)
            case .sold:
                return LocalizedString("sold", story: .home)
            case .unsold:
                return LocalizedString("unsold", story: .home)
            }
        }
    }
}
