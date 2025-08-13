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
        _ value: Value
    ) -> GenericSetResponse {
        return self.setGeneric(named: nil, value)
    }
}

extension UIResponder {
    
    func getIfGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        return (self as? GenericValueInterface)?.getGeneric(
            named: label,
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
        _ value: Value
    ) -> GenericSetResponse {
        return (self as? GenericValueInterface)?.setGeneric(
            named: label,
            value) ?? .noEffect
    }
    @discardableResult
    func setIfGeneric<Value>(
        _ value: Value
    ) -> GenericSetResponse {
        return (self as? GenericValueInterface)?.setGeneric(
            named: nil,
            value) ?? .noEffect
    }
}
