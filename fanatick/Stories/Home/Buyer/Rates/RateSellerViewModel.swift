//
//  RateSellerViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 11/18/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Alamofire
import Wires

class RateSellerViewModel: ViewModel {
    let listing: BehaviorRelay<Listing?> = BehaviorRelay(value: nil)
    let ratingOptions: BehaviorRelay<[RatingOption]> = BehaviorRelay(value: [])
    let rating: BehaviorRelay<Int?> = BehaviorRelay(value: nil)
    
    let submitButtonAction: PublishRelay<Void> = PublishRelay()
    let successAction: PublishRelay<Void> = PublishRelay()
    
    override init() {
        super.init()
        
        submitButtonAction
            .filter({ (_) -> Bool in
                return self.rating.value != nil
            })
            .flatMap({[weak self] (_) -> Single<Result<RatingParamsModel>> in
                let ratingParams = RatingParamsModel(
                    ratingOptions: self?.ratingOptions.value ?? [],
                    rating: self?.rating.value!,
                    sellerId: self?.listing.value?.seller?.id,
                    transactionId: self?.listing.value?.transaction?.id,
                    userId: FirebaseSession.shared.user.value?.id
                )
                return NetworkManager
                    .rx
                    .send(request: PostRating(ratings: ratingParams),
                          clazz: RatingParamsModel.self)
                .toResult()
                .do(onSuccess: { (_) in
                    ActivityIndicator.shared.stop()
                }, onSubscribe: { () in
                    ActivityIndicator.shared.start()
                })
            })
            .subscribe({ [weak self] (_) in
                self?.successAction.accept(())
            }).disposed(by: disposeBag)
    }
}
