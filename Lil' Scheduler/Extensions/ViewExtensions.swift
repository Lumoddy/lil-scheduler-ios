//
//  ViewExtensions.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit

extension UIView {
    
    public func setEnabled(_ enabled: Bool) -> ()? {
        switch self {
        case let self as UILabel:
            self.isEnabled = enabled
            return ()
        case let self as UIControl:
            self.isEnabled = enabled
            return ()
        default:
            return nil
        }
    }
    
    public func setReleventColor(_ color: UIColor) {
        switch self {
        case let self as UILabel:
            self.textColor = color
            return
        case let self as UIControl:
            self.tintColor = color
            return
        default:
            self.backgroundColor = color
            return
        }
    }
}
