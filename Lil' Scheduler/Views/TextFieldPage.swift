//
//  TextFieldPage.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// ### Receives:
/// * `"title"` : `String`
/// * `"label"` : `String`
/// * `"placeholder"` : `String`
/// * `"value"` or `"text"` or nil : `String`
/// ### Responds:
/// * `"value"` or `"text"` or nil : `String`
public class TextFieldPageTableViewCell
    : UITableViewCell,
    ValueReceiver,
    ValueResponder {
    
    private var _titleBuffer: String?? = nil
    private var _placeholderBuffer: String?? = nil
    private var _valueBuffer: String?? = nil
    private var _recentPage: TextFieldPageViewController? = nil
    
    public func instantiatePageView() -> UIViewController {

        let result = self.viewController!
            .storyboard!
            .instantiateViewController(
                withIdentifier: "TextFieldPage")
            as! TextFieldPageViewController

        result.listen { (value: String) in
            for listener in self._valueListeners {
                listener(value)
            }
        }
        
        result.listen(named: "back") { (_: ()) in
            let viewController = self.viewController!
            viewController.navigationController!.popToViewController(
                viewController,
                animated: true)
        }

        self._recentPage = result

        if let text = self._titleBuffer {
            result.title = text
        }
        if let text = self._placeholderBuffer {
            result.placeholder = text
        }
        if let text = self._valueBuffer {
            result.value = text
        }

        return result
    }
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._titleBuffer = nil
        self._placeholderBuffer = nil
        self._valueBuffer = nil
        self._recentPage = nil
        self._label.text = nil
        self._preview.text = nil
    }
    
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _preview: UILabel!
    
    public var label: String? {
        get { return self._label.text }
        set { self._label.text = newValue }
    }
    
    public var title: String? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.title
            }
            else {
                return self._titleBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.title = newValue
            }
            else {
                self._titleBuffer = newValue
            }
        }
    }
    
    public var placeholder: String? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.placeholder
            }
            else {
                return self._placeholderBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.placeholder = newValue
            }
            else {
                self._placeholderBuffer = newValue
            }
        }
    }
    
    public var value: String? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.value
            }
            else {
                return self._valueBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.value = newValue
            }
            else {
                self._valueBuffer = newValue
            }
            self._preview.text = newValue
        }
    }
    
    private var _valueListeners: [(String) -> ()] = []
    
    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        case ("label", let value as String?):
            self.label = value
            return ()
        case ("title", let value as String?):
            self.title = value
            return ()
        case ("placeholder", let value as String?):
            self.placeholder = value
            return ()
        case ("value", let value as String?),
            ("text", let value as String?),
            (nil, let value as String?):
            self.value = value
            return ()
        default:
            return nil
        }
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        case ("value", let listener as (String) -> ()),
            ("text", let listener as (String) -> ()),
            (nil, let listener as (String) -> ()):
            self._valueListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
}

/// ### Receives:
/// * `"title"` : `String?`
/// * `"label"` : `String?`
/// * `"placeholder"` : `String?`
/// * `"value"` or `"text"` or nil : `String?`
/// ### Responds:
/// * `"value"` or `"text"` or nil : `String`
/// * `"back"` or nil : `()`
///     * Expects navigation to pop back to calling view controller.
public class TextFieldPageViewController
    : UITableViewController,
    ValueReceiver,
    ValueResponder {
    
    private var _placeholderBuffer: String?? = nil
    private var _valueBuffer: String?? = nil
    
    @IBOutlet private var _field: UITextField!
    
    public override func viewDidLoad() {
        self._field.placeholder = self._placeholderBuffer ?? nil
        self._field.text = self._valueBuffer ?? nil
    }
    
    @IBAction private func _onDone() {
        let value = self.value ?? ""
        for listener in self._valueListeners {
            listener(value)
        }
        for listener in self._backListeners {
            listener(())
        }
        self._valueListeners.removeAll()
        self._backListeners.removeAll()
    }

    @IBAction private func _onCancel() {
        let value = self.value ?? ""
        for listener in self._valueListeners {
            listener(value)
        }
        self._valueListeners.removeAll()
        self._backListeners.removeAll()
    }
    
    @IBAction private func _onTextChange() { }

    public override var title: String? {
        get { return self.navigationItem.title }
        set { self.navigationItem.title = newValue }
    }
    
    public var placeholder: String? {
        get {
            if let field = self._field {
                return field.placeholder
            }
            else {
                return self._placeholderBuffer ?? nil
            }
        }
        set {
            if let field = self._field {
                field.placeholder = newValue
            }
            else {
                self._placeholderBuffer = newValue
            }
        }
    }
    
    public var value: String? {
        get {
            if let field = self._field {
                return field.text
            }
            else {
                return self._valueBuffer ?? nil
            }
        }
        set {
            if let field = self._field {
                field.text = newValue
            }
            else {
                self._valueBuffer = newValue
            }
        }
    }
    
    private var _valueListeners: [(String) -> ()] = []
    private var _backListeners: [(()) -> ()] = []
    
    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        case ("title", let value as String?):
            self.title = value
            return ()
        case ("placeholder", let value as String?):
            self.placeholder = value
            return ()
        case ("value", let value as String?),
            ("text", let value as String?),
            (nil, let value as String?):
            self.value = value
            return ()
        default:
            return nil
        }
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        case ("back", let listener as (()) -> ()),
            (nil, let listener as (()) -> ()):
            _backListeners.append(listener)
            return ()
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
