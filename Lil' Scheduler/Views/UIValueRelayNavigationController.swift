//
//  UIValueRelayNavigationController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

public class UIValueRelayNavigationController
    : UINavigationController,
    UIBoxedValueReceiver,
      UIBoxedValueResponder {
    
    func send(boxed value: Any) -> ()? {
        return (super.viewControllers.first
            as? any UIBoxedValueReceiver)?
            .send(boxed: value)
    }
    
    func listenFor(boxed callback: @escaping (Any?) -> ()) -> ()? {
        guard let controller =
            super.viewControllers.first as? any UIBoxedValueResponder
        else { return nil }
        return controller.listenFor(boxed: callback)
    }
}
