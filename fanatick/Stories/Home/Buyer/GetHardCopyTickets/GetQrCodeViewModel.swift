//
//  GetQrCodeViewModel.swift
//  fanatick
//
//  Created by Yashesh on 02/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Wires
import Alamofire

class GetQrCodeViewModel: ViewModel {
    let transactionId = BehaviorRelay<String?>(value: nil)
    let qrCode = BehaviorRelay<QRCode?>(value: nil)
    let qrCodeAction = PublishRelay<String>()
    
    
    override init() {
        super.init()
        
        qrCodeAction.flatMap { transactionId -> Single<Result<QRCode>> in
            return NetworkManager.rx.send(request:
                TransactionVerification.init(transaction: transactionId),
                                          clazz: QRCode.self)
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
                } else if let values = result.value {
                    self.qrCode.accept(values)
                }
            }).disposed(by: disposeBag)
    }
}
