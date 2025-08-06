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

extension UINavigationController {
    
    @discardableResult
    public func popToBeforeViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> [UIViewController]? {
        let viewControllers = self.viewControllers
        guard
            let selfIndex = viewControllers.lastIndex(of: viewController)
        else {
            return nil
        }
        self.setViewControllers(
            Array(viewControllers[..<selfIndex]),
            animated: animated)
        return Array(viewControllers[selfIndex...])
    }
}
