//
//  HomeViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/7/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel: ViewModel {
    let role = MenuViewModel.shared.role
}
