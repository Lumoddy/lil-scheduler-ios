//
//  TextFieldCell.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// ### Generic Gets:
/// * `"value"` or `"text"` or nil : `String`
///
/// ### Generic Sets:
/// * `"value"` or `"text"` or nil : `String?` or `(String) -> ()`
public class TextFieldTableViewCell
    : UITableViewCell,
    GenericValueInterface {
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._label?.text = nil
        self._field.placeholder = nil
        self._field.text = nil
    }
    
    @IBOutlet private var _label: UILabel?
    @IBOutlet private var _field: UITextField!
    
    @IBAction private func _onTextChange() {
        let value = self.value ?? ""
        for listener in self._valueListeners {
            listener(value)
        }
    }
    
    public var label: String? {
        get { return _label?.text }
        set { _label?.text = newValue }
    }
    
    public var placeholder: String? {
        get { return _field.placeholder }
        set { _field.placeholder = newValue }
    }
    
    public var value: String? {
        get { return _field.text }
        set {
            _field.text = newValue
            let value = newValue ?? ""
            for listener in _valueListeners {
                listener(value)
            }
        }
    }
    
    private var _valueListeners: [(String) -> ()] = []

    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        case "value" where type == String.self,
            "text" where type == String.self,
            nil where type == String.self:
            return self.value as! Value?
        default:
            return nil
        }
    }

    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        switch (label, value) {
        case ("value", let value as String?),
            ("text", let value as String?),
            (nil, let value as String?):
            self.value = value
            return .effect
        case ("value", let listener as (String) -> ()),
            ("text", let listener as (String) -> ()),
            (nil, let listener as (String) -> ()):
            self._valueListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
}
