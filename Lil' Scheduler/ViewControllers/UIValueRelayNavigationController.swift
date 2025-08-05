//
//  UIValueRelayNavigationController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

public class UIValueRelayNavigationController
    : UINavigationController,
    UIValueReceiver,
    UIValueResponder {

    func send<Key : CodingKey>(
        _ value: Any,
        forKey key: Key
    ) -> ()? {
        self.viewControllers.first?.sendIfReceiver(
            value,
            forKey: key)
    }
    
    func listen<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()
    ) -> ()? {
        self.viewControllers.first?.listenIfResponder(
            forKey: key,
            listener: listener)
    }
}
