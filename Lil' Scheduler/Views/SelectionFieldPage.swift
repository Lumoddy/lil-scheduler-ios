//
//  TextFieldPage.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

/// ### Generic Gets:
/// * `"value"` or nil : `IndexPath`
///
/// ### Generic Sets:
/// * `"value"` or nil : `IndexPath?` or `(IndexPath) -> ()`
public class SelectionFieldPageTableViewCell
    : UITableViewCell,
    GenericValueInterface {
    
    public class Section {
        
        public let header: String?
        public let footer: String?
        public let rows: [Option]
        
        public init(
            header: String? = nil,
            rows: [Option],
            footer: String? = nil
        ) {
            self.header = header
            self.rows = rows
            self.footer = footer
        }
    }
    
    public enum Option {
        case value(label: String)
        case inner(label: String, content: [Section])
    }
    
    private var _titleBuffer: String?? = nil
    private var _valueBuffer: IndexPath?? = nil
    private var _selectionsBuffer: [Section]?? = nil
    private var _recentPage: SelectionFieldPageViewController? = nil
    
    public func instantiatePageView() -> UIViewController {

        let result = self.viewController!
            .storyboard!
            .instantiateViewController(
                withIdentifier: "SelectionFieldPage")
            as! SelectionFieldPageViewController
        
        result.listen { (value: IndexPath) in
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
        if let value = self._selectionsBuffer {
            result.selections = value
        }
        if let value = self._valueBuffer {
            result.value = value
        }

        return result
    }
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._titleBuffer = nil
        self._valueBuffer = nil
        self._selectionsBuffer = nil
        self._recentPage = nil
        self._label?.text = nil
        self._preview?.text = nil
    }
    
    @IBOutlet private var _label: UILabel?
    @IBOutlet private var _preview: UILabel?
    
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
    
    public var selections: [Section]? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.selections
            }
            else {
                return self._selectionsBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.selections = newValue
            }
            else {
                self._selectionsBuffer = newValue
            }
            if let value = self.value {
                self._preview?.text = newValue?.label(at: value)
            }
            else {
                self._preview?.text = nil
            }
        }
    }
    
    public var value: IndexPath? {
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
            if let newValue = newValue {
                self._preview?.text = self.selections?.label(at: newValue)
            }
            else {
                self._preview?.text = nil
            }
        }
    }
    
    public var label: String? {
        get { return self._label?.text }
        set { self._label?.text = newValue }
    }
    
    private var _valueListeners: [(IndexPath) -> ()] = []

    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        case "value" where type == IndexPath.self,
            nil where type == IndexPath.self:
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
        case ("value", let value as IndexPath?),
            (nil, let value as IndexPath?):
            self.value = value
            return .effect
        case ("value", let listener as (IndexPath) -> ()),
            (nil, let listener as (IndexPath) -> ()):
            self._valueListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
}

extension [SelectionFieldPageTableViewCell.Section] {
    
    public func label(at: IndexPath) -> String? {
        var iterator = at.makeIterator()
        guard
            let section = iterator.next(),
            let row = iterator.next(),
            let next = self[safe: section]?.rows[safe: row]
        else {
            return nil
        }
        var current = next
        while true {
            switch current {
            case .inner(let label, let sections):
                guard let section = iterator.next() else {
                    return label
                }
                guard
                    let row = iterator.next(),
                    let next = sections[safe: section]?.rows[safe: row]
                else {
                    return nil
                }
                current = next
                continue
            case .value(let label):
                if iterator.next() != nil {
                    return nil
                }
                return label
            }
        }
    }
}

public class SelectionFieldPageViewController
    : UITableViewController {
    
    private var _path: IndexPath? = nil
    private var _value: IndexPath? = nil
    private var _selections: [SelectionFieldPageTableViewCell.Section]? = nil
    
    public var path: IndexPath? {
        get { return self._path }
        set { self._path = newValue }
    }
    
    public override var title: String? {
        get { return self.navigationItem.title }
        set { self.navigationItem.title = newValue }
    }
    
    public var selections: [SelectionFieldPageTableViewCell.Section]? {
        get { return self._selections }
        set {
            self._selections = newValue
            self.tableView.reloadData()
        }
    }
    
    public var value: IndexPath? {
        get { return self._value }
        set {
            self._value = newValue
            self.tableView.reloadData()
        }
    }
    
    @IBAction private func _onCancel() {
        for listener in self._backListeners {
            listener(())
        }
        self._valueListeners.removeAll()
        self._backListeners.removeAll()
    }
    
    private var _valueListeners: [(IndexPath) -> ()] = []
    private var _backListeners: [(()) -> ()] = []
    
    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        case ("title", let value as String?):
            self.title = value
            return ()
        case ("value", let value as IndexPath?),
            (nil, let value as IndexPath?):
            self.value = value
            return ()
        default:
            return nil
        }
    }
    
    func listen<Value>(
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch listener {
        case let listener as (()) -> ():
            self._backListeners.append(listener)
            return ()
        case let listener as (IndexPath) -> ():
            self._valueListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
    
    public override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return self._selections?.count ?? 0
    }
    
    public override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return self._selections?[section].header
    }

    public override func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {
        return self._selections?[section].footer
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return self._selections![section].rows.count
    }
    
    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch self._selections?[indexPath[0]].rows[indexPath[1]] {
        case nil:
            preconditionFailure()
        case .value(let label):
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Value",
                    for: indexPath)
                as! SelectionFieldPageViewControllerValueTableViewCell
            cell.label = label
            return cell
        case .inner(let label, let sections):
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Inner",
                    for: indexPath)
                as! SelectionFieldPageViewControllerInnerTableViewCell
            cell.label = label
            cell.value = self.value?[2...]
            cell.path = (self._path ?? []).appending(indexPath)
            cell.selections = sections
            cell.listen { (value: IndexPath) in
                for listener in self._valueListeners {
                    listener(value)
                }
            }
            cell.listen { (_: ()) in
                for listener in self._backListeners {
                    listener(())
                }
            }
            return cell
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch self._selections?[indexPath[0]].rows[indexPath[1]] {
        case nil:
            preconditionFailure()
        case .value(_):
            for listener in self._valueListeners {
                listener(indexPath)
            }
            for listener in self._backListeners {
                listener(())
            }
            break
        case .inner(_, _):
            let cell = tableView
                .cellForRow(at: indexPath)
                as! SelectionFieldPageViewControllerInnerTableViewCell
            self.navigationController!.pushViewController(
                cell.instantiatePageView(),
                animated: true)
            break
        }
    }
}

public class SelectionFieldPageViewControllerValueTableViewCell
    : UITableViewCell {
    
    public override func prepareForReuse() {
        self._label.text = nil
    }
    
    @IBOutlet private var _label: UILabel!
    
    public var label: String? {
        get { return self._label.text }
        set { self._label.text = newValue }
    }
}

/// ### Responds:
/// * `"value"` or nil : `String`
public class SelectionFieldPageViewControllerInnerTableViewCell
    : UITableViewCell {
    
    private var _path: IndexPath? = nil
    private var _valueBuffer: IndexPath?? = nil
    private var _selectionsBuffer: [SelectionFieldPageTableViewCell.Section]??
        = nil
    private var _recentPage: SelectionFieldPageViewController? = nil
    
    public func instantiatePageView() -> UIViewController {

        let result = self.viewController!
            .storyboard!
            .instantiateViewController(
                withIdentifier: "InnerSelectionFieldPage")
            as! SelectionFieldPageViewController

        result.listen { (value: IndexPath) in
            let value = self._path!.appending(value)
            for listener in self._valueListeners {
                listener(value)
            }
        }
        
        result.listen { (_: ()) in
            for listener in self._backListeners {
                listener(())
            }
        }

        self._recentPage = result

        if let value = self._valueBuffer {
            result.value = value
        }
        if let value = self._selectionsBuffer {
            result.selections = value
        }
        result.title = self.label

        return result
    }
    
    public override func prepareForReuse() {
        self._valueListeners.removeAll()
        self._backListeners.removeAll()
        self._valueBuffer = nil
        self._selectionsBuffer = nil
        self._recentPage = nil
        self._label!.text = nil
    }
    
    @IBOutlet private var _label: UILabel?
    
    public var path: IndexPath? {
        get { return self._path }
        set { self._path = newValue }
    }
    
    public var selections: [SelectionFieldPageTableViewCell.Section]? {
        get {
            if let recentPage = self._recentPage {
                return recentPage.selections
            }
            else {
                return self._selectionsBuffer ?? nil
            }
        }
        set {
            if let recentPage = self._recentPage {
                recentPage.selections = newValue
            }
            else {
                self._selectionsBuffer = newValue
            }
        }
    }
    
    public var value: IndexPath? {
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
        }
    }
    
    public var label: String? {
        get { return self._label!.text }
        set {
            self._label!.text = newValue
            self._recentPage?.navigationItem.title = newValue
        }
    }
        
    private var _valueListeners: [(IndexPath) -> ()] = []
    private var _backListeners: [(()) -> ()] = []
    
    func listen<Value>(
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch listener {
        case let listener as (IndexPath) -> ():
            self._valueListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
}
