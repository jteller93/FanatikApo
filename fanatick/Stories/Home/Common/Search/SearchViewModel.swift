//
//  SearchViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class SearchViewModel: ViewModel {
    let isLoading = BehaviorRelay<Bool>(value: false)
    let isEndReached = BehaviorRelay<Bool>(value: true)
    let query = BehaviorRelay<String>(value: "")
    let hasNext = BehaviorRelay<Bool>(value: true)
    let page = BehaviorRelay<Int?>(value: nil)
    let events = BehaviorRelay<[Event]>(value: [])
    let searchDate = Date()
    
    // MARK: Action
    let cellAction = PublishRelay<IndexPath>()
    let loadNextAction = PublishRelay<()>()
    
    override init() {
        super.init()
        
        query.do(onNext: { [weak self] (_) in
            self?.page.accept(nil)
            self?.hasNext.accept(true)
        }).map{ _ in return () }
        .bind(to: loadNextAction)
        .disposed(by: disposeBag)
        
        loadNextAction
            .flatMap{ [weak self] (_) -> Single<Result<AlgoliaEventResponse>> in
                return AlgoliaManager
                    .shared
                    .rx.search(queryString: self?.query.value ?? "",
                               startDate: self?.searchDate ?? Date(),
                               page: (self?.page.value ?? -1) + 1)
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
                    
                    self.hasNext.accept(value.hasNextPage)
                    
                    var newEvents = self.events.value
                    
                    if value.page ?? 0 == 0 {
                        newEvents = []
                    }
                    
                    newEvents.append(contentsOf: value.hits)
                    
                    self.page.accept(value.page)
                    self.events.accept(newEvents)
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
