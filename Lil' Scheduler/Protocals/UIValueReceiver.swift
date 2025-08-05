//
//  UIValueReceiver.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

protocol UIValueReceiver : UIResponder {
    
    func send<Key : CodingKey>(
        _ value: Any,
        forKey key: Key) -> ()?
}

struct UIValueReceiverHandler<Key : CodingKey & Hashable> : ~Copyable {
    
    private var _storedValues: [Key : Any] = [:]
    
    public mutating func handleSend<OtherKey : CodingKey>(
        _ value: Any,
        forKey key: OtherKey
    ) -> ()? {
        let convertedKey: Key
        if let key = key as? Key {
            convertedKey = key
        }
        else if
            let intValue = key.intValue,
            let key = Key(intValue: intValue) {
            convertedKey = key
        }
        else if
            let key = Key(stringValue: key.stringValue) {
            convertedKey = key
        }
        else {
            return nil
        }
        self._storedValues[convertedKey] = value
        return ()
    }
    
    public func get<Value>(_ type: Value.Type, forKey key: Key) -> Value? {
        return self._storedValues[key] as? Value
    }
}

extension UIViewController {
    
    func sendIfReceiver<Key : CodingKey>(
        _ value: Any,
        forKey key: Key
    ) -> ()? {
        return (self as? UIValueReceiver)?.send(
            value,
            forKey: key)
    }
}
