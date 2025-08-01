//
//  UIValueResponder.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

protocol UIBoxedValueReceiver : UIViewController {
    
    func send(boxed value: Any) -> ()?
}

protocol UIValueReceiver<Value> : UIViewController, UIBoxedValueReceiver {
    
    associatedtype Value
    
    func send(value: Value) -> ()?
}

extension UIValueReceiver {
    
    func send(boxed value: Any) -> ()? {
        if let value = value as? Value {
            return self.send(value: value)
        }
        else {
            return nil
        }
    }
}

extension UIViewController {
    
    public func sendIfReceiver<T>(value: T) -> ()? {
        switch self {
        case let self as any UIValueReceiver<T> :
            return self.send(value: value)
        case let self as any UIBoxedValueReceiver :
            return self.send(boxed: value)
        default:
            return nil
        }
    }
}
