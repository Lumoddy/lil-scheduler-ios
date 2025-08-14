//
//  DateFieldPage.swift
//  Lil' Scheduler
//
//  Created by 13878 on 12/8/2025.
//

import UIKit

/// ### Generic Gets:
/// * `"value"` or `"date"` or nil : `Date`
///
/// ### Generic Sets:
/// * `"value"` or `"date"` or nil : `Date?`
/// * `"value"` or `"date"` or nil : `(Date) -> ()`
public class DateFieldPageTableViewCell
    : UITableViewCell,
    GenericValueInterface {
    
    private var _titleBuffer: String?? = nil
    private var _valueBuffer: Date?? = nil
    private var _modeBuffer: UIDatePicker.Mode?? = nil
    private var _preferredStyleBuffer: UIDatePickerStyle?? = nil
    private var _recentPage: DateFieldPageViewController? = nil
    
    public func instantiatePageView() -> UIViewController {

        let result = self.viewController!
            .storyboard!
            .instantiateViewController(
                withIdentifier: "DateFieldPage")
            as! DateFieldPageViewController

        result.listen { (value: Date) in
            for listener in self._valueListeners {
                listener(value)
            }
        }
        
        result.listen { (_: ()) in
            let viewController = self.viewController!
            viewController.navigationController!.popToViewController(
                viewController,
                animated: true)
        }

        self._recentPage = result

        if let text = self._titleBuffer {
            result.title = text
        }
        if let text = self._valueBuffer {
            result.value = text
        }

        return result
    }
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._titleBuffer = nil
        self._valueBuffer = nil
        self._recentPage = nil
        self._label?.text = nil
        self._preview?.text = nil
    }
    
    @IBOutlet private var _label: UILabel?
    @IBOutlet private var _preview: UILabel?
    
    public var label: String? {
        get { return self._label?.text }
        set { self._label?.text = newValue }
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

    public var value: Date? {
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
            self._updatePreview()
        }
    }
    
    public var mode: UIDatePicker.Mode? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.mode
            }
            else {
                return self._modeBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.mode = newValue
            }
            else {
                self._modeBuffer = newValue
            }
            self._updatePreview()
        }
    }
    
    public var preferredStyle: UIDatePickerStyle? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.preferredStyle
            }
            else {
                return self._preferredStyleBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.preferredStyle = newValue
            }
            else {
                self._preferredStyleBuffer = newValue
            }
        }
    }
    
    private func _updatePreview() {
        switch (self.mode, self.value) {
        case (.countDownTimer?, let date?):
            self._preview?.text = (Date(
                timeIntervalSince1970: 0)..<date)
                    .formatted(.interval)
            break
        case (.date?, let date?):
            self._preview?.text = date.formatted(
                Date.FormatStyle()
                    .year(.defaultDigits)
                    .month(.abbreviated)
                    .day(.twoDigits))
            break
        case (.dateAndTime?, let date?):
            self._preview?.text = date.formatted(
                Date.FormatStyle()
                    .year(.defaultDigits)
                    .month(.abbreviated)
                    .day(.twoDigits)
                    .hour(.defaultDigits(amPM: .abbreviated))
                    .minute(.twoDigits))
            break
        case (.time?, let date?):
            self._preview?.text = date.formatted(
                Date.FormatStyle()
                    .hour(.defaultDigits(amPM: .abbreviated))
                    .minute(.twoDigits))
            break
        case (.yearAndMonth?, let date?):
            self._preview?.text = date.formatted(
                Date.FormatStyle()
                    .year(.defaultDigits)
                    .month(.abbreviated))
            break
        default:
            self._preview?.text = nil
            break
        }
    }
    
    private var _valueListeners: [(Date) -> ()] = []

    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        case "value" where type == Date.self,
            "text" where type == Date.self,
            nil where type == Date.self:
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
        case ("value", let value as Date?),
            ("text", let value as Date?),
            (nil, let value as Date?):
            self.value = value
            return .effect
        case ("value", let listener as (Date) -> ()),
            ("text", let listener as (Date) -> ()),
            (nil, let listener as (Date) -> ()):
            self._valueListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
}

public class DateFieldPageViewController
    : UIViewController {
    
    private var _valueBuffer: Date?? = nil
    private var _modeBuffer: UIDatePicker.Mode?? = nil
    private var _preferredStyleBuffer: UIDatePickerStyle?? = nil
    
    @IBOutlet private var _field: UIDatePicker!
    
    public override func viewDidLoad() {
        self._field.date = (self._valueBuffer ?? nil) ?? Date.now
    }
    
    @IBAction private func _onDone() {
        let value = self.value ?? Date.now
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
        for listener in self._backListeners {
            listener(())
        }
        self._valueListeners.removeAll()
        self._backListeners.removeAll()
    }
    
    @IBAction private func _onTextChange() { }

    public override var title: String? {
        get { return self.navigationItem.title }
        set { self.navigationItem.title = newValue }
    }
    
    public var value: Date? {
        get {
            if let field = self._field {
                return field.date
            }
            else {
                return self._valueBuffer ?? nil
            }
        }
        set {
            if let field = self._field {
                field.date = newValue ?? Date.now
            }
            else {
                self._valueBuffer = newValue
            }
        }
    }
    
    public var mode: UIDatePicker.Mode? {
        get {
            if let field = self._field {
                return field.datePickerMode
            }
            else {
                return self._modeBuffer ?? nil
            }
        }
        set {
            if let field = self._field {
                field.datePickerMode = newValue ?? .date
            }
            else {
                self._modeBuffer = newValue
            }
        }
    }
    
    public var preferredStyle: UIDatePickerStyle? {
        get {
            if let field = self._field {
                return field.preferredDatePickerStyle
            }
            else {
                return self._preferredStyleBuffer ?? nil
            }
        }
        set {
            if let field = self._field {
                field.preferredDatePickerStyle = newValue ?? .automatic
            }
            else {
                self._preferredStyleBuffer = newValue
            }
        }
    }
    
    private var _valueListeners: [(Date) -> ()] = []
    private var _backListeners: [(()) -> ()] = []
    
    func listen<Value>(
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch listener {
        case let listener as (()) -> ():
            _backListeners.append(listener)
            return ()
        case let listener as (Date) -> ():
            _valueListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
}
