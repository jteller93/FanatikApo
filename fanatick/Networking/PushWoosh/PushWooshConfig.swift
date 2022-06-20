//
//  PushWooshConfig.swift
//  fanatick
//
//  Created by Yashesh on 29/07/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import Pushwoosh
import UserNotificationsUI
import RxSwift
import RxCocoa

class PushWooshObserver: ViewModel {
    
    static let shared = PushWooshObserver()
    let notificationReceiver = BehaviorRelay<(Bool?)>(value: nil)
}

