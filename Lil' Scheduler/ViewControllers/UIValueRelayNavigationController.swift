//
//  UIValueRelayNavigationController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

/// ### Receives:
/// * `Any` : `Any`
///     * Relayed to the top-most `viewController`.
/// ### Responds:
/// * `Any` : `Any`
///     * Relayed to the top-most `viewController`.
public class UIValueRelayNavigationController
    : UINavigationController,
    ValueReceiver,
    ValueResponder {

    func send<Value>(
        named label: String?,
        _ value: Value
    ) -> ()? {
        self.viewControllers.last?.sendIfReceiver(
            named: label,
            value)
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        self.viewControllers.last?.listenIfResponder(
            named: label,
            with: listener)
    }
}
