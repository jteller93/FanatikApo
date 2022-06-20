//
//  ViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    let error: BehaviorRelay<RuntimeError?> = BehaviorRelay(value: nil)
    let disposeBag = DisposeBag()
}
