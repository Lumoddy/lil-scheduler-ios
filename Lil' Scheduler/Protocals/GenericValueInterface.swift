//
//  GenericValueInterface.swift
//  Lil' Scheduler
//
//  Created by 13878 on 11/8/2025.
//

import UIKit

enum GenericSetResponse {
    case noEffect
    case effect
    case caught
}

/// Objects, UIViews or UIViewControllers can implement this protocal to give
/// it the ability to send values without having to know what its being sent
/// to.
///
/// ```swift
/// (receiver: any GenericValueInterface) in
/// // unlabeled string:
/// receiver.set("some string")
/// _ = receiver.get(String.self)
/// // labeled int:
/// receiver.set(named: "length", 5)
/// _ = receiver.get(named: "length", Int.self)
/// ```
/// ```swift
/// (view: UIViewController) in
/// // unlabeled string:
/// view.setIfGeneric("same string")
/// _ = view.getIfGeneric(String.self)
/// ```
///
/// Normally, values are sent without labels and are handled by identifying
/// their type but labels can be used as well if needed.
///
/// ## API Note
/// Implementers should also support values with labels if they support
/// without.
protocol GenericValueInterface {
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type) -> Value?
    
    @discardableResult
    func setGeneric<Value>(
        named label: String?,
        _ type: Value.Type,
        _ value: Value) -> GenericSetResponse
}

extension GenericValueInterface {
    
    func getGeneric<Value>(
        _ type: Value.Type
    ) -> Value? {
        return self.getGeneric(named: nil, type)
    }
    
    @discardableResult
    func setGeneric<Value>(
        _ type: Value.Type,
        _ value: Value
    ) -> GenericSetResponse {
        return self.setGeneric(named: nil, type, value)
    }
    @discardableResult
    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        return self.setGeneric(named: label, Value.self, value)
    }
    @discardableResult
    func setGeneric<Value>(
        _ value: Value
    ) -> GenericSetResponse {
        return self.setGeneric(named: nil, Value.self, value)
    }
}

extension UIResponder {
    
    func getIfGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        return (self as? GenericValueInterface)?.getGeneric(
            named: nil,
            type)
    }
    func getIfGeneric<Value>(
        _ type: Value.Type
    ) -> Value? {
        return (self as? GenericValueInterface)?.getGeneric(
            named: nil,
            type)
    }
    
    @discardableResult
    func setIfGeneric<Value>(
        named label: String?,
        _ type: Value.Type,
        _ value: Value
    ) -> GenericSetResponse {
        return (self as? GenericValueInterface)?.setGeneric(
            named: label,
            type,
            value) ?? .noEffect
    }
    @discardableResult
    func setIfGeneric<Value>(
        _ type: Value.Type,
        _ value: Value
    ) -> GenericSetResponse {
        return (self as? GenericValueInterface)?.setGeneric(
            named: nil,
            type,
            value) ?? .noEffect
    }
    @discardableResult
    func setIfGeneric<Value>(
        _ value: Value
    ) -> GenericSetResponse {
        return (self as? GenericValueInterface)?.setGeneric(
            named: nil,
            Value.self,
            value) ?? .noEffect
    }
}

extension UIView {
    
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// searching breadth-first.
    @discardableResult
    func setAllGenericInside<Value>(
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericInside(
            named: nil,
            value,
            ignoreCatches: ignoreCatches)
    }
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// searching breadth-first.
    @discardableResult
    func setAllGenericInside<Value>(
        named label: String?,
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        var result = GenericSetResponse.noEffect
        var subviewArray = self.subviews.map { $0 as UIView? }
        for i in 0..<subviewArray.count {
            if let subview = subviewArray[i] as? GenericValueInterface {
                switch subview.setGeneric(named: label, value) {
                case GenericSetResponse.caught where !ignoreCatches:
                    subviewArray[i] = nil
                default:
                    break
                }
            }
        }
        for i in 0..<subviewArray.count {
            guard let subResult = subviewArray[i]?.setAllGenericInside(
                named: label,
                value) else {
                continue
            }
            switch (result, subResult) {
            case (.noEffect, .effect),
                (.noEffect, .caught),
                (.effect, .caught):
                result = subResult
                break
            default:
                break
            }
        }
        return result
    }
    
    /// Calls `sendIfReceiver()` on all superviews and then calls
    /// `sendOutside()` on the containing `UIViewController` if there is one.
    @discardableResult
    func setAllGenericOutside<Value>(
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericOutside(named: nil, value, until: until)
    }
    /// Calls `sendIfReceiver()` on all superviews and then calls
    /// `sendOutside()` on the containing `UIViewController` if there is one.
    @discardableResult
    func setAllGenericOutside<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        if self == until {
            return .noEffect
        }
        else if let superview = self.superview {
            if let superview = superview as? GenericValueInterface {
                switch superview.setGeneric(named: label, value) {
                case .caught where !ignoreCatches:
                    return .caught
                default:
                    break
                }
            }
            return superview.setAllGenericOutside(
                named: label,
                value,
                until: until)
        }
        else if let viewController = self.viewController {
            if let viewController = viewController as? GenericValueInterface {
                switch viewController.setGeneric(named: label, value) {
                case .caught where !ignoreCatches:
                    return .caught
                default:
                    break
                }
            }
            return viewController.setAllGenericOutside(
                named: label,
                value,
                until: until)
        }
        else {
            return .noEffect
        }
    }
}

extension UIViewController {
    
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// controller breadth-first.
    @discardableResult
    func setAllGenericInside<Value>(
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericInside(
            named: nil,
            value,
            ignoreCatches: ignoreCatches)
    }
    /// Calls `sendIfReceiver()` on all views contained inside this view
    /// controller breadth-first.
    @discardableResult
    func setAllGenericInside<Value>(
        named label: String?,
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        if let view = self.view {
            if let view = view as? GenericValueInterface {
                switch view.setGeneric(named: label, value) {
                case .caught where !ignoreCatches:
                    return .caught
                default:
                    break
                }
            }
            return view.setAllGenericInside(named: label, value)
        }
        else {
            return .noEffect
        }
    }
    
    /// Calls `sendIfReceiver()` on all parent view controllers.
    @discardableResult
    func setAllGenericOutside<Value>(
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericOutside(
            named: nil,
            value,
            until: until,
            ignoreCatches: ignoreCatches)
    }
    /// Calls `sendIfReceiver()` on all parent view controllers.
    @discardableResult
    func setAllGenericOutside<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        if self == until {
            return .noEffect
        }
        else if let parent = self.parent {
            if let parent = parent as? GenericValueInterface {
                switch parent.setGeneric(named: label, value) {
                case .caught where !ignoreCatches:
                    return .caught
                default:
                    break
                }
            }
            return parent.setAllGenericOutside(
                named: label,
                value,
                until: until)
        }
        else {
            return .noEffect
        }
    }
    
    /// Calls `sendIfReceiver()` on all view controllers above this one on the
    /// navigation stack.
    @discardableResult
    func setAllGenericAbove<Value>(
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericAbove(
            named: nil,
            value,
            ignoreCatches: ignoreCatches)
    }
    /// Calls `sendIfReceiver()` on all view controllers above this one on the
    /// navigation stack.
    @discardableResult
    func setAllGenericAbove<Value>(
        named label: String?,
        _ value: Value,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        if let navigationController = self.navigationController {
            var result = GenericSetResponse.noEffect
            var foundSelf = false
            for viewController in navigationController.viewControllers {
                if foundSelf {
                    switch (viewController as? GenericValueInterface)?
                        .setGeneric(named: label, value) {
                    case GenericSetResponse.caught? where !ignoreCatches:
                        return .caught
                    case _?:
                        result = .effect
                        break
                    default:
                        break
                    }
                }
                else if viewController === self {
                    foundSelf = true
                }
            }
            return result
        }
        else {
            return .noEffect
        }
    }
    
    /// Calls `sendIfReceiver()` on all `UIViewController`s below this one on
    /// the stack and also the presenting `UIViewController` if there is one.
    @discardableResult
    func setAllGenericBelow<Value>(
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        return self.setAllGenericBelow(
            named: nil,
            value,
            until: until,
            ignoreCatches: ignoreCatches)
    }
    /// Calls `sendIfReceiver()` on all `UIViewController`s below this one on
    /// the stack and also the presenting `UIViewController` if there is one.
    @discardableResult
    func setAllGenericBelow<Value>(
        named label: String?,
        _ value: Value,
        until: UIResponder? = nil,
        ignoreCatches: Bool = false
    ) -> GenericSetResponse {
        if let navigationController = self.navigationController {
            var result = GenericSetResponse.noEffect
            var foundSelf = false
            for
                viewController in navigationController.viewControllers
                    .reversed() {
                if foundSelf {
                    switch (viewController as? GenericValueInterface)?
                        .setGeneric(named: label, value) {
                    case GenericSetResponse.caught? where !ignoreCatches:
                        return .caught
                    case _?:
                        result = .effect
                        break
                    default:
                        break
                    }
                }
                else if viewController === self {
                    foundSelf = true
                }
            }
            if let presentingViewController = navigationController
                .presentingViewController {
                switch (presentingViewController as? GenericValueInterface)?
                    .setGeneric(named: label, value) {
                case GenericSetResponse.caught? where !ignoreCatches:
                    return .caught
                default:
                    break
                }
                return presentingViewController.setAllGenericBelow(
                    named: label,
                    value,
                    until: until)
            }
            return result
        }
        else if let presentingViewController = self.presentingViewController {
            switch (presentingViewController as? GenericValueInterface)?
                .setGeneric(named: label, value) {
            case GenericSetResponse.caught? where !ignoreCatches:
                return .caught
            default:
                break
            }
            return presentingViewController.setAllGenericBelow(
                named: label,
                value,
                until: until)
        }
        else {
            return .noEffect
        }
    }
}
