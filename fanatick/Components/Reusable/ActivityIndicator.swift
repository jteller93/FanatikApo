//
//  ActivityIndicator.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Vincent Ngo. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class ActivityIndicator: UIActivityIndicatorView {
    static let shared: ActivityIndicator = ActivityIndicator()
    
    init() {
        super.init(frame: CGRect(x:0.0, y:0.0, width:40.0, height:40.0))
        self.hidesWhenStopped = true
        self.style = UIActivityIndicatorView.Style.large
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func start() {
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        keyWindow?.addSubview(self)
        
        constrain(self) { view in
            view.centerY == view.superview!.centerY
            view.centerX == view.superview!.centerX
        }
        
        startAnimating()
    }
    
    func stop() {
        stopAnimating()
        removeFromSuperview()
    }
    
}
