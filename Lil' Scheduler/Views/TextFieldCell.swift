//
//  TextFieldCell.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// ### Responds:
/// * `"value"` or `"text"` or nil : `String`
public class TextFieldTableViewCell
    : UITableViewCell,
    ValueResponder {
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._label.text = nil
        self._field.placeholder = nil
        self._field.text = nil
    }
    
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _field: UITextField!
    
    @IBAction private func _onTextChange() {
        let value = self.value ?? ""
        for listener in self._valueListeners {
            listener(value)
        }
    }
    
    public var label: String? {
        get { return _label.text }
        set { _label.text = newValue }
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
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        case ("value", let listener as (String) -> ()),
            ("text", let listener as (String) -> ()),
            (nil, let listener as (String) -> ()):
            _valueListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
}
