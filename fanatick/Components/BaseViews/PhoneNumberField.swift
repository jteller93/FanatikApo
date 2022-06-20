//
//  PhoneNumberField.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PhoneNumberField: TextField {
    var isValid: Bool {
        return String.isValidMobileNumber(text ?? "")
    }
    override func applyStyling() {
        super.applyStyling()
        
        clearButtonMode = .whileEditing
        
        placeholder = LocalConstant.phoneNumberPlaceholder
        
        keyboardType = .phonePad
        
        if let clearButton = value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage.init(named: "icon_clear"), for: .normal)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let clearButton = value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage.init(named: "icon_clear"), for: .normal)
        }
    }
    
    override var text: String? {
        get {
            return StringFormatter.deformattedPhoneNumber(number: super.text)
        }
        set {
            super.text = StringFormatter.formattedPhoneNumber(newValue)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (super.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        if StringFormatter.deformattedPhoneNumber(number: newString).count > String.LocalConstant.phoneNumberLength {
            return false
        }
        text = StringFormatter.formattedPhoneNumber(newString)
        sendActions(for: .valueChanged)
        return false
    }
    
    private struct LocalConstant {
        static let phoneNumberPlaceholder = "(XXX) XXX-XXXX"
    }
}

extension Reactive where Base: PhoneNumberField {
    var isValid: Observable<Bool> {
        return text.orEmpty.map{ String.isValidMobileNumber($0) }
    }
}
