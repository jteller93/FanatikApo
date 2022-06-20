//
//  PickerView.swift
//  fanatick
//
//  Created by Yashesh on 31/05/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit

class PickerView: UIPickerView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Change color of selected section line.
        subviews[1].backgroundColor = .fanaticLightGray_205_205_205
        subviews[2].backgroundColor = .fanaticLightGray_205_205_205
    }
}
