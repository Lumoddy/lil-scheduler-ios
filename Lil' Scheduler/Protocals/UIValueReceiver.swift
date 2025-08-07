//
//  UIValueReceiver.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// Objects, UIViews or UIViewControllers can implement this protocal to give
/// it the ability to send values without having to cast to each relevent type.
///
/// ```swift
/// (receiver: any ValueReceiver) in
/// // unlabeled string:
/// receiver.send("some string")
/// // labeled int:
/// receiver.send(named: "length", 5)
/// ```
/// ```swift
/// (view: UIViewController) in
/// // unlabeled string:
/// view.sendIfReceiver("some string")
/// ```
///
/// Normally, values are sent without labels and are handled by identifying
/// their type but labels can be used as well if needed.
///
/// ## API Note
/// Implementers should also support values with labels if they support
/// without.
protocol ValueReceiver {
    
    func send<Value>(named label: String?, _ value: Value) -> ()?
}

extension ValueReceiver {
    
    func send<Value>(_ value: Value) -> ()? {
        return self.send(named: nil, value)
    }
}

extension UIViewController {
    
    func sendIfReceiver<Value>(
        _ value: Value
    ) -> ()? {
        return (self as? ValueReceiver)?.send(value)
    }
    func sendIfReceiver<Value>(
        named label: String,
        _ value: Value
    ) -> ()? {
        return (self as? ValueReceiver)?.send(named: label, value)
    }
}
