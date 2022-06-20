//
//  Separator.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit

class Separator: View {
    
    override func setupSubviews() {
        super.setupSubviews()
        
        constrain(self) { separator in
            separator.height == 1
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
    }
}
