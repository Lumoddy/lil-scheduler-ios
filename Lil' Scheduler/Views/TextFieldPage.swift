//
//  TextFieldPage.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

public class TextFieldPageTableViewCell
    : UITableViewCell,
    UIValueResponder {
    
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

        result.listen(
            forKey: UIValueResponderDefaultResultKey()
        ) { (value: String) in
            self._listener?(value)
        }
        
        result.listen(
            forKey: TextFieldPageViewController.ReturnKey()
        ) { (_: ()) in
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
    
    private var _listener: ((String) -> ())? = nil
    
    func listen<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()
    ) -> ()? {
        switch key.stringValue {
        case UIValueResponderDefaultResultKey.stringValue:
            if let listener = listener as? (String) -> () {
                self._listener = { value in
                    listener(value)
                    self._preview.text = value
                }
            }
            else {
                self._listener = nil
            }
            return ()
        default:
            return nil
        }
    }
    
    public override func prepareForReuse() {
        self._listener = nil
        self._titleBuffer = nil
        self._placeholderBuffer = nil
        self._valueBuffer = nil
        self._recentPage = nil
        self._label.text = nil
        self._preview.text = nil
    }
    
    @IBOutlet private var _label: UILabel!
    @IBOutlet private var _preview: UILabel!
    
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
    
    public var label: String? {
        get { return self._label.text }
        set { self._label.text = newValue }
    }
}

public class TextFieldPageViewController
    : UITableViewController,
    UIValueResponder {
    
    struct ReturnKey : CodingKey, Hashable {
        
        public static let stringValue = "return"
        public static let intValue = {
            var hasher = Hasher()
            stringValue.hash(into: &hasher)
            return hasher.finalize()
        }()

        public init() { }
        
        public var stringValue: String { ReturnKey.stringValue }
        
        public init?(stringValue: String) {
            if stringValue == ReturnKey.stringValue {
                self.init()
            }
            else {
                return nil
            }
        }
        
        public var intValue: Int? { ReturnKey.intValue }
        
        public init?(intValue: Int) {
            if intValue == ReturnKey.intValue {
                self.init()
            }
            else {
                return nil
            }
        }
    }
    
    private var _isTransitioningBack = false
    private var _returnAction: (() -> ())? = nil
    private var _listener: ((String) -> ())? = nil
    
    func listen<Key : CodingKey, Value>(
        forKey key: Key,
        listener: @escaping (Value) -> ()
    ) -> ()? {
        switch key.stringValue {
        case UIValueResponderDefaultResultKey.stringValue:
            self._listener = listener as? (String) -> ()
            return ()
        case ReturnKey.stringValue:
            if let listener = listener as? (()) -> () {
                self._returnAction = { listener(()) }
            }
            return ()
        default:
            return nil
        }
    }

    private var _placeholderBuffer: String?? = nil
    private var _valueBuffer: String?? = nil
    
    @IBOutlet private var _field: UITextField!
    
    public override func viewDidLoad() {
        self._field.placeholder = self._placeholderBuffer ?? nil
        self._field.text = self._valueBuffer ?? nil
    }

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
    
    @IBAction private func _onDone() {
        if self._isTransitioningBack { return }
        self._listener?(self._field.text ?? "")
        self._returnAction!()
        self._isTransitioningBack = true
    }

    @IBAction private func _onCancel() {
        if self._isTransitioningBack { return }
        self._returnAction!()
        self._isTransitioningBack = true
    }
    
    @IBAction private func _onTextChange() { }
}
