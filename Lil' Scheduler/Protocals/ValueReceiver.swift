//
//  UIValueReceiver.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// Objects, UIViews or UIViewControllers can implement this protocal to give
/// it the ability to send values without having to know what its being sent
/// to.
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
        return self.sendIfReceiver(named: nil, value)
    }
    func sendIfReceiver<Value>(
        named label: String?,
        _ value: Value
    ) -> ()? {
        return (self as? ValueReceiver)?.send(named: label, value)
    }
}

extension UIView {
    
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// searching breadth-first.
    func sendInside<Value>(
        _ value: Value
    ) -> ()? {
        return self.sendInside(named: nil, value)
    }
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// searching breadth-first.
    func sendInside<Value>(
        named label: String?,
        _ value: Value
    ) -> ()? {
        var result: ()? = nil
        for subview in self.subviews {
            if let subview = subview as? ValueReceiver {
                subview.send(named: label, value)
            }
        }
        for subview in self.subviews {
            if subview.sendInside(named: label, value) != nil {
                result = ()
            }
        }
        return result
    }
    
    /// Calls `sendIfReceiver()` on all superviews and then calls
    /// `sendOutside()` on the containing `UIViewController` if there is one.
    func sendOutside<Value>(
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        return self.sendOutside(named: nil, value, until: until)
    }
    /// Calls `sendIfReceiver()` on all superviews and then calls
    /// `sendOutside()` on the containing `UIViewController` if there is one.
    func sendOutside<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        if self == until {
            return nil
        }
        else if let superview = self.superview {
            if let superview = superview as? ValueReceiver {
                superview.send(named: label, value)
            }
            return superview.sendOutside(named: label, value, until: until)
        }
        else if let viewController = self.viewController {
            if let viewController = viewController as? ValueReceiver {
                viewController.send(named: label, value)
            }
            return viewController.sendOutside(named: label, value, until: until)
        }
        else {
            return nil
        }
    }
}

extension UIViewController {
    
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// controller breadth-first.
    func sendInside<Value>(
        _ value: Value
    ) -> ()? {
        return self.sendInside(named: nil, value)
    }
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// controller breadth-first.
    func sendInside<Value>(
        named label: String?,
        _ value: Value
    ) -> ()? {
        if let view = self.view {
            if let view = view as? ValueReceiver {
                view.send(named: label, value)
            }
            return view.sendInside(named: label, value)
        }
        else {
            return nil
        }
    }
    
    /// Calls `sendIfReceiver()` on all parent view controllers.
    func sendOutside<Value>(
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        return self.sendOutside(named: nil, value, until: until)
    }
    /// Calls `sendIfReceiver()` on all parent view controllers.
    func sendOutside<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        if self == until {
            return nil
        }
        else if let parent = self.parent {
            if let parent = parent as? ValueReceiver {
                parent.send(named: label, value)
            }
            return parent.sendOutside(named: label, value, until: until)
        }
        else {
            return nil
        }
    }
    
    /// Calls `sendIfReceiver()` on all view controllers above this one on the
    /// navigation stack.
    func sendAbove<Value>(
        _ value: Value
    ) -> ()? {
        return self.sendAbove(named: nil, value)
    }
    /// Calls `sendIfReceiver()` on all view controllers above this one on the
    /// navigation stack.
    func sendAbove<Value>(
        named label: String?,
        _ value: Value
    ) -> ()? {
        if let navigationController = self.navigationController {
            var result: ()? = nil
            var foundSelf = false
            for viewController in navigationController.viewControllers {
                if foundSelf {
                    if
                        let viewController = viewController as? ValueReceiver,
                        viewController.send(named: label, value) != nil {
                        result = ()
                    }
                }
                else if viewController === self {
                    foundSelf = true
                }
            }
            return result
        }
        else {
            return nil
        }
    }
    
    /// Calls `sendIfReceiver()` on all `UIViewController`s below this one on
    /// the stack and also the presenting `UIViewController` if there is one.
    func sendBelow<Value>(
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        return self.sendBelow(named: nil, value, until: until)
    }
    /// Calls `sendIfReceiver()` on all `UIViewController`s below this one on
    /// the stack and also the presenting `UIViewController` if there is one.
    func sendBelow<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil
    ) -> ()? {
        if let navigationController = self.navigationController {
            var result: ()? = nil
            var foundSelf = false
            for
                viewController in navigationController.viewControllers
                    .reversed() {
                if foundSelf {
                    if
                        let viewController = viewController as? ValueReceiver,
                        viewController.send(named: label, value) != nil {
                        result = ()
                    }
                }
                else if viewController === self {
                    foundSelf = true
                }
            }
            if let presentingViewController
                = navigationController.presentingViewController {
                if
                    let presentingViewController
                        = presentingViewController as? ValueReceiver {
                    presentingViewController.send(named: label, value)
                }
                return presentingViewController.sendBelow(
                    named: label,
                    value,
                    until: until)
            }
            return result
        }
        else if let presentingViewController = self.presentingViewController {
            if
                let presentingViewController
                    = presentingViewController as? ValueReceiver {
                presentingViewController.send(named: label, value)
            }
            return presentingViewController.sendBelow(
                named: label,
                value,
                until: until)
        }
        else {
            return nil
        }
    }
}
