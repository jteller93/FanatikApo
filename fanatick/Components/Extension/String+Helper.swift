//
//  String+Helper.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

private let emailRegex = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

extension String {
    func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
        return components(separatedBy: characterSet).joined(separator: replacementString)
    }
    
    func isValidEmail() -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPassword() -> Bool {
        return count >= LocalConstant.minPasswordLength
    }
    
    func isValidName() -> Bool {
        return !isEmpty
    }
    
    func isNotEmpty() -> Bool {
        return !isEmpty
    }
    
    static func isValidMobileNumber(_ number: String?) -> Bool {
        let count = number?.count ?? 0
        return count >= String.LocalConstant.phoneNumberLength
    }
    
    // MARK: Constants
    struct LocalConstant {
        static let minPasswordLength = 6
        static let phoneNumberLength = 10
    }
    
    //Add colon to string
    func addColon() -> String {
        return self + ":"
    }
    
    //Convert string to json
    func getJsonObject() -> [String: AnyObject]? {
        let data = self.data(using: .utf8)!
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String: AnyObject] {
                return json
            } else {
                return nil
            }
        } catch _ {
            return nil
        }
    }
}

extension String {
    var numbers: String {
        return filter { "0"..."9" ~= $0 }
    }
}

class StringFormatter {
    static func deinternalizedPhoneNumber(_ number: String?) -> String {
        guard let number = number else { return "" }
        return number.replacingOccurrences(of: "+1", with: "")
    }
    
    static func internalizedPhoneNumber(_ number: String?) -> String {
        guard let number = number else { return "" }
        if !number.starts(with: "+1") {
            return "+1\(number)"
        }
        return number
    }
    
    static func formattedPhoneNumber(_ number: String?) -> String {
        guard var number = number else { return "" }
        
        // Format: (XXX) XXX-XXXX
        
        // Remove characters other than digits
        number = StringFormatter.deformattedPhoneNumber(number: number)
        
        // Take the first 10 digits into consideration
        if number.count >= String.LocalConstant.phoneNumberLength {
            let index = number.index(number.startIndex, offsetBy: String.LocalConstant.phoneNumberLength - 1)
            number = String(number[...index])
        }
        
        // Add necessary separators
        if number.count > 0 {
            number.insert("(", at: number.index(number.startIndex, offsetBy: 0))
        }
        if number.count > 4 {
            number.insert(")", at: number.index(number.startIndex, offsetBy: 4))
        }
        if number.count > 5 {
            number.insert(" ", at: number.index(number.startIndex, offsetBy: 5))
        }
        if number.count > 9 {
            number.insert("-", at: number.index(number.startIndex, offsetBy: 9))
        }
        
        return number
    }
    
    static func deformattedPhoneNumber(number: String?) -> String {
        let allowed = CharacterSet.decimalDigits
        return number?.replaceCharactersFromSet(characterSet: allowed.inverted) ?? ""
    }
    
    
}
