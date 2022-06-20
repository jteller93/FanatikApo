//
//  Scope.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation

protocol HasScopeFunc {
    
}

extension HasScopeFunc {
    @discardableResult
    @inline(__always) func apply(_ closure:(Self) -> ()) -> Self {
        closure(self)
        return self
    }
    
    @discardableResult
    @inline(__always) func run<R>(_ closure:(Self) -> R) -> R {
        return closure(self)
    }
    
    @discardableResult
    @inline(__always) func takeIf(_ predicate: (Self) -> Bool) -> Self? {
        return predicate(self) ? self : nil
    }
}

extension NSObject: HasScopeFunc {}

extension Array: HasScopeFunc {}
