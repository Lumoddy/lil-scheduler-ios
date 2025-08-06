//
//  UIValueResponder.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

struct UIValueResponderDefaultResultKey : CodingKey, Hashable {
    
    public static let stringValue = "value"
    public static let intValue = {
        var hasher = Hasher()
        stringValue.hash(into: &hasher)
        return hasher.finalize()
    }()

    public init() { }
    
    public var stringValue: String { UIValueResponderDefaultResultKey.stringValue }
    
    public init?(stringValue: String) {
        if stringValue == UIValueResponderDefaultResultKey.stringValue {
            self.init()
        }
        else {
            return nil
        }
    }
    
    public var intValue: Int? { UIValueResponderDefaultResultKey.intValue }
    
    public init?(intValue: Int) {
        if intValue == UIValueResponderDefaultResultKey.intValue {
            self.init()
        }
        else {
            return nil
        }
    }
}

protocol UIValueResponder : UIResponder {
    
    func listen<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()) -> ()?
}

extension UIValueResponder {
    
    func listen<Key : CodingKey>(
        forKey key: Key,
        listener: @escaping () -> ()
    ) -> ()? {
        self.listen(forKey: key, listener: { (_: ()) in listener() })
    }
}

struct UIValueResponderHandler<Key : CodingKey & Hashable> : ~Copyable {
    
    private var _stored: [Key : (Any) -> ()?] = [:]
    
    public mutating func handleListen<OtherKey : CodingKey, Value>(
        forKey key: OtherKey,
        listener: @escaping (Value) -> ()
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
        self._stored[convertedKey] = { value in
            if let value = value as? Value {
                listener(value)
                return ()
            }
            else {
                return nil
            }
        }
        return ()
    }
    
    public func respond<Value>(forKey key: Key, with value: Value) -> ()? {
        return self._stored[key]?(value)
    }
}

extension UIViewController {
    
    func listenIfResponder<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()
    ) -> ()? {
        return (self as? UIValueResponder)?.listen(
            forKey: key,
            listener: listener)
    }
}
