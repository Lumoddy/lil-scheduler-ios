//
//  TextFieldCell.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

public class TextFieldTableViewCell
    : UITableViewCell,
      UIValueResponder {
    
    private var _listener: ((String) -> ())? = nil
    
    func listen<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()
    ) -> ()? {
        switch key.stringValue {
        case UIValueResponderDefaultResultKey.stringValue:
            self._listener = listener as? (String) -> ()
            return ()
        default:
            return nil
        }
    }
    
    public override func prepareForReuse() {
        self._listener = nil
        self._label.text = nil
        self._field.placeholder = nil
        self._field.text = nil
    }
    
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _field: UITextField!
    
    @IBAction private func _onTextChange() {
        self._listener?(self.value ?? "")
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
            self._listener?(newValue ?? "")
        }
    }
}
