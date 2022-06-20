//
//  SellerConfirmationViewMode.swift
//  fanatick
//
//  Created by Yashesh on 21/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import RxCocoa
import RxSwift
import Wires
import Alamofire

class SellerConfirmationViewModel: ViewModel {
    let list = BehaviorRelay<Listing?>(value: nil)
}
