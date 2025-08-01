//
//  UIValueResponder.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

protocol UIBoxedValueResponder : UIViewController {
    
    func listenFor(boxed callback: @escaping (Any?) -> ()) -> ()?
}

protocol UIValueResponder<Value> : UIViewController, UIBoxedValueResponder {
    
    associatedtype Value
    
    func listenFor(completion callback: @escaping (Value?) -> ()) -> ()?
}

extension UIValueResponder {
    
    func listenFor(boxed callback: @escaping (Any?) -> ()) -> ()? {
        return self.listenFor(completion: { callback($0) })
    }
}

extension UIViewController {
    
    public func listenIfResponderFor<T>(
        completion callback: @escaping (T?) -> ()
    ) -> ()? {
        switch self {
        case let self as any UIValueResponder<T> :
            return self.listenFor(completion: callback)
        case let self as any UIBoxedValueResponder :
            return self.listenFor {
                if let value = $0 as? T {
                    callback(value)
                }
            }
        default:
            return nil
        }
    }
}
