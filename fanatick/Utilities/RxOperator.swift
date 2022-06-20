//
//  RxOperator.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/18/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

// Two way binding operator between control property and relay, that's all it takes.
infix operator <-> : DefaultPrecedence

func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument
    
    guard let rangeAll = textInput.textRange(from: start, to: end),
        let text = textInput.text(in: rangeAll) else {
            return nil
    }
    
    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }
    
    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        let endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
            return text
    }
    
    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}

func <-> <Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    let bindToUIDisposable = relay.bind(to: textInput.text)
    
    let bindToRelay = textInput.text
        .subscribe(onNext: { [weak base = textInput.base] n in
            guard let base = base else {
                return
            }
            
            let nonMarkedTextValue = nonMarkedText(base)
            
            if let nonMarkedTextValue = nonMarkedTextValue, nonMarkedTextValue != relay.value {
                relay.accept(nonMarkedTextValue)
            }
            }, onCompleted:  {
                bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToRelay)
}

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = relay.bind(to: property)
    let bindToRelay = property
        .subscribe(onNext: { n in
            relay.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })
    
    return Disposables.create(bindToUIDisposable, bindToRelay)
}

extension ControlProperty {
    func bindBoth(_ relay: BehaviorRelay<E>) -> Disposable {
        return self<->relay
    }
}

extension BehaviorRelay where Element == Bool  {
    func negate() {
        accept(!value)
    }
}

extension BehaviorRelay where Element == Int {
    func increment() {
        accept(value + 1)
    }
    
    func decrement() {
        accept(value - 1)
    }
}
