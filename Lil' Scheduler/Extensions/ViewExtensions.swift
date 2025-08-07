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
        animated: Bool,
        orDismiss: Bool = false
    ) -> [UIViewController]? {
        let viewControllers = self.viewControllers
        guard
            let selfIndex = viewControllers.lastIndex(of: viewController)
        else {
            return nil
        }
        if orDismiss && selfIndex == 0 {
            self.dismiss(animated: animated)
            return viewControllers
        }
        else {
            self.setViewControllers(
                Array(viewControllers[..<selfIndex]),
                animated: animated)
            return Array(viewControllers[selfIndex...])
        }
    }
    
    @discardableResult
    public func replaceTopViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) -> UIViewController? {
        var viewControllers = self.viewControllers
        let lastIndex = viewControllers.count - 1
        guard lastIndex != -1 else {
            self.setViewControllers([viewController], animated: animated)
            return nil
        }
        let oldViewController = viewControllers[lastIndex]
        viewControllers[lastIndex] = viewController
        self.setViewControllers(viewControllers, animated: animated)
        return oldViewController
    }
}
