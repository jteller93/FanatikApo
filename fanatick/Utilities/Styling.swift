//
//  Styling.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import NutsAndBolts

extension UIColor {
    @nonobjc class var fanatickYellow: UIColor {
        return UIColor(red: 252 / 255, green: 208 / 255, blue: 0 / 255, alpha: 1)
    }
    
    @nonobjc class var fanatickGrey: UIColor {
        return UIColor(red: 53 / 255, green: 53 / 255, blue: 53 / 255, alpha: 1.0)
    }
    
    @nonobjc class var fanatickLighterGrey: UIColor {
        return UIColor(red: 179 / 255, green: 179 / 255, blue: 179 / 255, alpha: 1.0)
    }
    
    @nonobjc class var fanatickLightGrey: UIColor {
        return UIColor(red: 155 / 255, green: 155 / 255, blue: 155 / 255, alpha: 1.0)
    }
    
    @nonobjc class var fanatickWhite: UIColor {
        return UIColor(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0)
    }
    
    @nonobjc class var fanatickBlack: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    @nonobjc class var fanaticLightGray_66_66_66: UIColor {
        return UIColor.getColorFrom(red: 66, green: 66, blue: 66)
    }
    
    @nonobjc class var fanaticLightGray_205_205_205: UIColor {
        return UIColor.getColorFrom(red: 205, green: 205, blue: 205)
    }
    
    @nonobjc class var fanatickGray_151_151_151: UIColor {
        return UIColor.getColorFrom(red: 151, green: 151, blue: 151)
    }
    
    @nonobjc class var fanatickGray_90_90_90: UIColor {
        return UIColor.getColorFrom(red: 90, green: 90, blue: 90)
    }
    
    @nonobjc class var fanatickGray_74_74_74: UIColor {
        return UIColor.getColorFrom(red: 74, green: 74, blue: 74)
    }
    
    @nonobjc class var fanatickGray_142_142_142: UIColor {
        return UIColor.getColorFrom(red: 142, green: 142, blue: 142)
    }
    
    @nonobjc class var fanatickblack_alpa_70: UIColor {
        return UIColor.getColorFrom(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    @nonobjc private class func getColorFrom(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}

enum FontWeight: String {
    case regular = "Regular"
    case medium = "Medium"
    case bold = "Bold"
    case light = "Light"
    case ultralight = "UtraLight"
    case italic = "Italic"
}

enum FontType: String {
    case helveticaNeue = "HelveticaNeue"
    case sfProDisplay = "SFProDisplay"
    case staatliches = "Staatliches"
}

extension UIFont {
    class func shFont(size: CGFloat, fontType: FontType, weight: FontWeight) -> UIFont {
        if let font = UIFont.init(name: "\(fontType.rawValue)-\(weight.rawValue)", size: size) {
            return font
        } else {
            var systemWeight = UIFont.Weight.regular
            switch weight {
            case .regular:
                systemWeight = UIFont.Weight.regular
            case .medium:
                systemWeight = UIFont.Weight.medium
            case .bold:
                systemWeight = UIFont.Weight.bold
            case .light:
                systemWeight = UIFont.Weight.light
            case .ultralight:
                systemWeight = .ultraLight
            case .italic:
                return UIFont.systemFont(ofSize: size, weight: systemWeight).italic()
            }
            
            return UIFont.systemFont(ofSize: size, weight: systemWeight)
        }
    }
}

class Styling {
    static func applyDefaultStyling() {
        UINavigationBar.applyDefaultStyling()
        UIBarButtonItem.applyDefaultStyling()
        UIToolbar.applyDefaultStyling()
        UISearchBar.styleDefaults()
//        UILabel.appearance().textColor = .fanatickWhite
        UISegmentedControl.applyDefaultStyling()
    }
}
