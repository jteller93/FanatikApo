//
//  SegmentedControl.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/15/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    class func applyDefaultStyling() {
        let selected = [NSAttributedString.Key.foregroundColor: UIColor.fanatickGrey,
                                   NSAttributedString.Key.font: UIFont.shFont(size: 13,
                                                                              fontType: .sfProDisplay,
                                                                              weight: .regular)]
        let unselected = [NSAttributedString.Key.foregroundColor: UIColor.fanatickYellow,
                                   NSAttributedString.Key.font: UIFont.shFont(size: 13,
                                                                              fontType: .sfProDisplay,
                                                                              weight: .regular)]
        UISegmentedControl.appearance().setTitleTextAttributes(selected, for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes(unselected, for: .normal)
        if #available(iOS 13.0, *) {
            UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.fanatickYellow
        } else {
            UISegmentedControl.appearance().tintColor = UIColor.fanatickYellow
        }
        
    }
}

class SegmentedControl: UISegmentedControl {
    
    func updateCorner(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.borderColor = UIColor.fanatickYellow.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
    }
}
