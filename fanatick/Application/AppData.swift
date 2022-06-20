//
//  AppData.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/11/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

class AppData {
    static let shared = AppData()
    
    var didShowTutorial: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "DidShowTutorialKey")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "DidShowTutorialKey")
            UserDefaults.standard.synchronize()
        }
    }
}
