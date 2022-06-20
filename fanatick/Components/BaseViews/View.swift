//
//  View.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class View: UIView {
    var disposeBag = DisposeBag()
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
        applyStyling()
        addObservers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        applyStyling()
        addObservers()
    }
    
    func applyStyling() {
        
    }
    
    func setupSubviews() {
        
    }
    
    func addObservers() {
        
    }
}
