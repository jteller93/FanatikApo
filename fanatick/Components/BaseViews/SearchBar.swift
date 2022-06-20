//
//  SearchBar.swift
//  fanatick
//
//  Created by Vincent Ngo on 5/3/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

class SearchBar: UISearchBar {
    
}

public extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        }
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.first { $0 is UITextField }) as? UITextField else { return nil }
        return tf
    }
    
    var cancelButton: UIButton? {
        let svs = subviews.flatMap { $0.subviews }
        guard let button = (svs.first { $0 is UIButton }) as? UIButton else { return nil }
        if button.titleLabel?.text != nil {
            return button
        }
        return button
    }
    
    var placeholderLabel: UILabel? {
        if let label = (textField?.subviews.first { $0 is UILabel }) as? UILabel {
            return label
        }
        return nil
    }
    
    func applyDefaultStyling() {
        backgroundColor = .fanatickWhite
        setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        isTranslucent = true
        showsCancelButton = false
        
        layer.cornerRadius = 3
        layer.masksToBounds = true
        
        textField?.leftView = UIImageView(image: UIImage(named: "icon_search"))
        textField?.textAlignment = .left
        textField?.backgroundColor = .clear
        textField?.font = UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)
        
        textField?.clearButtonMode = .never
        textField?.textColor = .fanatickLighterGrey
        textField?.tintColor = .fanatickLighterGrey
        placeholderLabel?.textColor = .fanatickLighterGrey
        
    }
    
    func hideLeftView() {
        textField?.leftView = nil
    }
    
    class func styleDefaults() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.fanatickLighterGrey, NSAttributedString.Key.font: UIFont.shFont(size: 16, fontType: .sfProDisplay, weight: .medium)]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitlePositionAdjustment(UIOffset.zero, for: .default)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchController.self]).setTitlePositionAdjustment(UIOffset.zero, for: .default)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchController.self]).setTitleTextAttributes(attributes, for: .normal)
    }
}
