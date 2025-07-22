//
//  ViewExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit

extension UIView {
    
    public func trySetEnabled(_ enabled: Bool) -> ()? {
        switch self {
        case let self as UILabel:
            self.isEnabled = enabled
            return ()
        case let self as UIControl:
            self.isEnabled = enabled
            return ()
        case let self as UIControl:
            self.isEnabled = enabled
            return ()
        default:
            return nil
        }
    }
    
}
