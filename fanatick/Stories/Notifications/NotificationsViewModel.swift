//
//  NotificationsViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Wires
import Alamofire

class NotificationsViewModel: ViewModel {
    
    let notifications = BehaviorRelay<[Notifications]>(value: [])
    
    let notificationAction = PublishRelay<()>()
    
    override init() {
        super.init()
        
        notificationAction
            .flatMap { _ -> Single<Result<[Notifications]>> in
                
                return NetworkManager.rx.send(request:
                    GetNotificaitons.init(), arrayClass: [Notifications].self)
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
                   self.notifications.accept(values)
                }
            }).disposed(by: disposeBag)
    }
}
