//
//  UIValueResponder.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// Objects, UIViews or UIViewControllers can implement this protocal to give
/// it the ability to respond to values without having to cast to each relevent
/// type.
///
/// ```swift
/// (responder: any ValueResponder) in
/// // unlabeled string:
/// responder.listen(with: { /* ... */ })
/// // labeled int:
/// responder.listen(named: "count") {
///     (value: Int) in
///     // ...
/// }
/// // specified float:
/// responder.listen(for: Float.self) {
///     value in
///     // ...
/// }
/// ```
/// ```swift
/// (view: UIViewController) in
/// // unlabeled string:
/// view.listenIfResponder {
///     (text: String) in
///     // ...
/// }
/// ```
///
/// Normally, values are sent without labels and are handled by identifying
/// their type but labels can be used as well if needed. 
///
/// ## API Note
/// Implementers should also support listeners with labels if they support
/// without.
protocol ValueResponder {
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()?
}

extension ValueResponder {
    
    public func listen<Value>(
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return self.listen(named: nil, with: listener)
    }
    public func listen<Value>(
        for: Value.Type,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return self.listen(named: nil, with: listener)
    }
    public func listen<Value>(
        for: Value.Type,
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return self.listen(named: label, with: listener)
    }
    public func listen(
        with event: @escaping () -> ()
    ) -> ()? {
        return self.listen(named: nil, with: { (_: ()) in event() })
    }
}

extension UIViewController {
    
    public func listenIfResponder<Value>(
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return (self as? ValueResponder)?.listen(with: listener)
    }
    public func listenIfResponder<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return (self as? ValueResponder)?.listen(named: label, with: listener)
    }
    public func listenIfResponder<Value>(
        for: Value.Type,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return (self as? ValueResponder)?.listen(with: listener)
    }
    public func listenIfResponder<Value>(
        for: Value.Type,
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        return (self as? ValueResponder)?.listen(named: label, with: listener)
    }
}
