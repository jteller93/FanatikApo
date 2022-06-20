//
//  LocationViewModel.swift
//  fanatick
//
//  Created by Yashesh on 04/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import Alamofire
import Wires

class LocationViewModel: ViewModel {

    let locationUpdate = PublishRelay<CLLocationCoordinate2D>()
    
    override init() {
        super.init()
        
        locationUpdate
            .throttle(5, scheduler: MainScheduler.instance)
            .flatMap { coordinates -> Single<Result<Location>> in
            let ticketsModel = UpdateLocation.init(location: UserLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
            return NetworkManager.rx.send(request: ticketsModel, clazz: Location.self)
                .toResult()
                .do(onSuccess: { (response) in }, onSubscribed: {})
            }.subscribe(onNext: { [weak self] (result) in
                if let error = result.error?.runtimeError {
                    self?.error.accept(error)
                }
            }).disposed(by: disposeBag)
    }
}
