//
//  TextField.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/12/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit

class TextField: UITextField, UITextFieldDelegate {
    var cursorRectPoint: CGPoint = CGPoint(x: 14, y: 0)
    var showCursor = true {
        didSet {
            setNeedsDisplay()
        }
    }
    var placeholderColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
    
    override var placeholder: String? {
        get {
            return attributedPlaceholder?.string
        }
        
        set {
            attributedPlaceholder = NSAttributedString(string: newValue ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
    }
    private var realDelegate: UITextFieldDelegate?
    
    // Keep track of the text field's real delegate
    override var delegate: UITextFieldDelegate? {
        get {
            return realDelegate
        }
        set {
            realDelegate = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
        setupSubviews()
        applyStyling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        setupSubviews()
        applyStyling()
    }
    
    func setupSubviews() {
        
    }
    
    func customInit() {
        super.delegate = self

    }
    
    func applyStyling() {
        
    }
    
    func defaultGrayBorderStyling(cornerRadius: CGFloat = K.Dimen.textFieldHeight / 2) {
        textColor = .fanatickLightGrey
        placeholderColor = UIColor.fanatickLightGrey.withAlphaComponent(0.7)
        layer.borderColor = UIColor.fanatickLightGrey.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.cornerRadius =  cornerRadius
    }
 
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: cursorRectPoint,
                      size: CGSize(width: bounds.size.width - cursorRectPoint.x * 2, height: bounds.size.height))
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: cursorRectPoint,
                      size: CGSize(width: bounds.size.width - cursorRectPoint.x * 2, height: bounds.size.height))
    }
    
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let original = super.clearButtonRect(forBounds: bounds)
        return original.offsetBy(dx: -cursorRectPoint.x, dy: cursorRectPoint.y)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let realDelegate = realDelegate, realDelegate.responds(to: aSelector) {
            return realDelegate
        } else {
            return super.forwardingTarget(for: aSelector)
        }
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if let realDelegate = realDelegate, realDelegate.responds(to: aSelector) {
            return true
        } else {
            return super.responds(to: aSelector)
        }
    }
    
    // Cursor
    override func caretRect(for position: UITextPosition) -> CGRect {
        return showCursor ? super.caretRect(for: position) : .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return showCursor ? super.selectionRects(for: range) : []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if !showCursor && (action == #selector(copy(_:)) ||
            action == #selector(selectAll(_:)) ||
            action == #selector(paste(_:))) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
