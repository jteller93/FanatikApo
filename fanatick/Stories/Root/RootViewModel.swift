//
//  RootViewModel.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/30/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RootViewModel: ViewModel {
    let selectMenuAction = MenuViewModel.shared.selectAction
}
