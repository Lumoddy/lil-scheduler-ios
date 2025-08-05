//
//  ViewExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit

extension UIResponder {
    
    public var viewController: UIViewController? {
        get {
            var target: UIResponder? = self
            while target != nil && !(target is UIViewController) {
                target = target?.next
            }
            return target as? UIViewController
        }
    }
}
