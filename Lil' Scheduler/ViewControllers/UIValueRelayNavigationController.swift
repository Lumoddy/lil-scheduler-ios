//
//  UIValueRelayNavigationController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

/// ### Generic Gets:
/// * `Any` : `Any`
///     * Relayed to the top-most `viewController`.
///
/// ### Generic Sets:
/// * `Any` : `Any`
///     * Relayed to the top-most `viewController`.
public class UIValueRelayNavigationController
    : UINavigationController,
    GenericValueInterface {
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        self.viewControllers.last?.getIfGeneric(
            named: label,
            type)
    }

    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        self.viewControllers.last?.setIfGeneric(
            named: label,
            value) ?? GenericSetResponse.noEffect
    }
}
