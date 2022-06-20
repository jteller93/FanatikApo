//
//  VerificationField.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Cartography
import UIKit
import RxSwift
import RxCocoa

class VerificationField: UIControl, UITextFieldDelegate, InputFieldDelegate {
    var disposeBag = DisposeBag()
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSubviews()
        applyStyling()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        applyStyling()
    }
    
    private let stackView = UIStackView()
    private var textFields: [InputField] = []
    private(set) var verificationCode: String = ""
    
    var isValid: Bool {
        return verificationCode.count == count
    }
    var count: Int = 6 {
        didSet {
            stackView.arrangedSubviews.forEach { (view) in
                view.removeFromSuperview()
            }
            textFields.removeAll()
            verificationCode = ""
            for _ in 0..<count {
                let input = InputField()
                input.delegate = self
                input.deleteDelegate = self
                stackView.addArrangedSubview(input)
                textFields.append(input)
            }
        }
    }
    var spacing: CGFloat {
        get {
            return stackView.spacing
        }
        
        set {
            stackView.spacing = newValue
        }
    }
    
    func setupSubviews() {
        
        addSubview(stackView)
        
        constrain(stackView) { stackView in
            stackView.edges == stackView.superview!.edges
        }
    }
    
    func applyStyling() {
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 15
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var fieldIndex: Int? = nil
        
        for (index, inputField) in textFields.enumerated() {
            if inputField == textField {
                fieldIndex = index
            }
        }
        
        if let index = fieldIndex {
            if string == "" { // deleted
                if index > 0 {
                    let previousIndex = index - 1
                    textFields[previousIndex].becomeFirstResponder()
                }
                textField.text = string
            } else { // new character
                if index < textFields.count - 1 {
                    let nextIndex = index + 1
                    textField.text = string
                    textFields[nextIndex].becomeFirstResponder()
                } else { // last index
                    textField.text = string
                    textField.resignFirstResponder()
                }
            }
        }
        
        verificationCode = ""
        for field in textFields {
            verificationCode += (field.text ?? "")
        }
        sendActions(for: .valueChanged)
        
        return false
    }
    
    fileprivate func inputFieldDidDelete(_ inputField: InputField) {
        for (index, textField) in textFields.enumerated() {
            if inputField == textField, index > 0 {
                let previousIndex = index - 1
                textFields[previousIndex].becomeFirstResponder()
            }
        }
    }
}

fileprivate protocol InputFieldDelegate {
    func inputFieldDidDelete(_ inputField: InputField)
}

fileprivate class InputField: TextField {
    enum HighlightState {
        case highlighted
        case normal
    }
    var deleteDelegate: InputFieldDelegate? = nil
    let underline = View()
    var underlineColor: UIColor = .fanatickWhite {
        didSet {
            updateUnderline()
        }
    }
    var highlightState: HighlightState = . normal {
        didSet {
            updateUnderline()
        }
    }
    
    override func setupSubviews() {
        addSubview(underline)
        
        highlightState = .normal
        
        constrain(underline) { underline in
            underline.bottom == underline.superview!.bottom
            underline.leading == underline.superview!.leading
            underline.trailing == underline.superview!.trailing
            underline.height == 1
        }
    }
    
    override func applyStyling() {
        super.applyStyling()
        
        showCursor = false
        cursorRectPoint = CGPoint(x: 0, y: 0)
        textAlignment = .center
        keyboardType = .numberPad
        font = UIFont.shFont(size: 60, fontType: .helveticaNeue, weight: .ultralight)
        textColor = .fanatickWhite
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightState = .normal
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highlightState = .highlighted
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        deleteDelegate?.inputFieldDidDelete(self)
    }
    
    private func updateUnderline() {
        switch highlightState {
        case .highlighted:
            underline.backgroundColor = underlineColor
        case .normal:
            underline.backgroundColor = underlineColor.withAlphaComponent(0.4)
        }
    }
}

extension Reactive where Base: VerificationField {
    var verificationCode: ControlProperty<String> {
        return controlProperty(editingEvents: .valueChanged, getter: { (base) -> String in
            return base.verificationCode
        }, setter: { (base: VerificationField, string: String) in
            // GET ONLY
        })
    }
    
    var isValid: ControlProperty<Bool> {
        return controlProperty(editingEvents: .valueChanged, getter: { (base) -> Bool in
            return base.isValid
        }, setter: { (base: VerificationField, valid: Bool) in
            // GET ONLY
        })
    }
}

