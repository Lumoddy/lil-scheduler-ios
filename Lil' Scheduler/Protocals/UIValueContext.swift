//
//  UIValueContext.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

protocol UIValueContext : UIResponder {
    
    func get<Key : CodingKey, Value>(
        _ type: Value.Type,
        forKey key: Key) -> Value?
}

extension UIResponder {
    
    func getContext<Key : CodingKey, Value>(
        _ type: Value.Type,
        forKey key: Key) -> Value?
    {
        if let self = self as? UIValueContext,
            let result = self.get(
                Value.self,
                forKey: key) {
            return result
        }
        else {
            return self.next?.getContext(Value.self, forKey: key)
        }
    }
}
