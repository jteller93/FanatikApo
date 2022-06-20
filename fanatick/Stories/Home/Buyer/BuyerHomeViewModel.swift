
//
//  HomeViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class BuyerHomeViewModel: ViewModel {
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isEndReached = BehaviorRelay<Bool>(value: true)
    let hasNext = BehaviorRelay<Bool>(value: true)
    let page = BehaviorRelay<Int?>(value: nil)
    let todayEvents = BehaviorRelay<[Event]>(value: [])
    let futureEvents = BehaviorRelay<[Event]>(value: [])
    let searchDate = Date()
    let facets = BehaviorRelay<[Facet]>(value: [])
    let selectedFacet = BehaviorRelay<Facet?>(value: nil)
    
    // MARK: Action
    let todayCellAction = PublishRelay<IndexPath>()
    let cellAction = PublishRelay<IndexPath>()
    let loadNextAction = PublishRelay<()>()
    
    func resetSearch() {
        isLoading.accept(false)
        isEndReached.accept(true)
        hasNext.accept(true)
        page.accept(nil)
        todayEvents.accept([])
        futureEvents.accept([])
    }
    
    override init() {
        super.init()
        
        selectedFacet.skip(1)
            .subscribe(onNext: { [weak self] (_) in
                self?.resetSearch()
                self?.loadNextAction.accept(())
            }).disposed(by: disposeBag)
        
        AlgoliaManager.shared.rx.searchFacets()
            .toResult()
            .subscribe(onSuccess: { [weak self] (response) in
                if let facets = response.value?.facetHits {
                    self?.facets.accept(facets)
                }
            }, onError: {_ in })
            .disposed(by: disposeBag)
        
        loadNextAction
            .flatMap{ [weak self] (_) -> Single<Result<AlgoliaEventResponse>> in
                return AlgoliaManager
                    .shared
                    .rx
                    .search(queryString: "",
                            startDate: self?.searchDate ?? Date(),
                            page: (self?.page.value ?? -1) + 1,
                            facet: self?.selectedFacet.value?.value)
                    .toResult()
                    .do(onSuccess: { [weak self] (_) in
                        self?.isLoading.accept(false)
                        ActivityIndicator.shared.stop()
                    }, onSubscribe: { [weak self] in
                        self?.isLoading.accept(true)
                        ActivityIndicator.shared.start()
                    })
            }.subscribe(onNext: { [weak self] (result) in
                if let error = result.error {
                    self?.error.accept(error.runtimeError)
                } else if var value = result.value, let `self` = self {
                    value.hits.sort(by: { (e1, e2) -> Bool in
                        return (e1.startAt ?? "") < (e2.startAt ?? "")
                    })
                    let today = value.hits.takeToday()
                    let future = value.hits.takeFuture()
                    self.hasNext.accept(value.hasNextPage)
                    
                    var todayEvents = self.todayEvents.value
                    todayEvents.append(contentsOf: today)
                    var futureEvents = self.futureEvents.value
                    futureEvents.append(contentsOf: future)
                    self.page.accept(value.page)
                    self.todayEvents.accept(todayEvents)
                    self.futureEvents.accept(futureEvents)
                }
            }).disposed(by: disposeBag)
        
        isEndReached
            .distinctUntilChanged()
            .map{ [weak self] isEnd -> Bool in
                guard let `self` = self else { return false}
                return isEnd && !self.isLoading.value && self.hasNext.value
            }.filter{ $0 }
            .map{ _ -> () in return () }
            .bind(to: loadNextAction)
            .disposed(by: disposeBag)
    }
}

