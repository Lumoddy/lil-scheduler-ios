//
//  TaskDetailScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 13/8/2025.
//

import UIKit
import FirebaseAuth

/// ### Generic Gets:
/// * `"task"` or nil : `TaskDescription`
///
/// ### Generic Sets:
/// * `"task"` or nil : `TaskDescription`
/// * `"task"` or nil : `(TaskDescription) -> ()`
/// * `"delete"` : `(()) -> ()`
public class TaskDetailScreenViewController
    : UITableViewController,
    GenericValueInterface {
    
    @IBAction private func _doDone() {
        let task = self.task
        for listener in self._taskListeners {
            listener(task)
        }
        self.navigationController!.popToBeforeViewController(
            self,
            animated: true,
            orDismiss: true)
    }

    @IBAction private func _doCancel() {
        self.navigationController!.popToBeforeViewController(
            self,
            animated: true,
            orDismiss: true)
    }
    
    private var _taskTitle: String = "New Task"
    private var _taskDescription: String = ""
    private var _taskAttributes: [TaskAttributeDescription] = []
    
    public var task: TaskDescription {
        get {
            return .init(
                title: self._taskTitle,
                description: self._taskDescription,
                color: RGB.white,
                attributes: self._taskAttributes)
        }
        set {
            self._taskTitle = newValue.title
            self._taskDescription = newValue.descriptionText
            self._taskAttributes = newValue.attributes?.map { $0 } ?? []
            self.tableView.reloadData()
        }
    }
    
    private var _taskListeners: [(TaskDescription) -> ()] = []
    private var _deleteListeners: [(()) -> ()] = []
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        case "task" where type == TaskDescription.self,
            nil where type == TaskDescription.self:
            return self.task as! Value?
        default:
            return nil
        }
    }
    
    @discardableResult
    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        switch (label, value) {
        case ("task", let value as TaskDescription),
            (nil, let value as TaskDescription):
            self.task = value
            return .effect
        case ("task", let listener as (TaskDescription) -> ()),
            (nil, let listener as (TaskDescription) -> ()):
            self._taskListeners.append(listener)
            return .caught
        case ("delete", let listener as (()) -> ()):
            self._deleteListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
    
    public override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1 + self._taskAttributes.count + 1 + 1
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return 2
        case 1..<(self._taskAttributes.count + 1):
            let index = section - 1
            switch self._taskAttributes[index] {
            case .duration:
                return 1
            case .fixedDate:
                return 1
            case .priority:
                return 1
            }
        case self._taskAttributes.count + 1:
            return 1
        case self._taskAttributes.count + 2:
            return 1
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TextFieldInline",
                    for: indexPath) as! TextFieldTableViewCell
                cell.label = "Title"
                cell.setGeneric(self._taskTitle)
                cell.setGeneric { newValue in
                    self._taskTitle = newValue
                    tableView.reloadData()
                }
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TextField",
                    for: indexPath) as! TextFieldPageTableViewCell
                cell.title = "Description"
                cell.label = "Description"
                cell.setGeneric(self._taskDescription)
                cell.setGeneric { newValue in
                    self._taskDescription = newValue
                    tableView.reloadData()
                }
                return cell
            default:
                preconditionFailure()
            }
        case 1..<(self._taskAttributes.count + 1):
            let index = indexPath.section - 1
            switch self._taskAttributes[index] {
            case .duration(let timeInterval):
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "DateField",
                        for: indexPath) as! DateFieldPageTableViewCell
                    cell.title = "Duration"
                    cell.label = "Duration"
                    cell.mode = .countDownTimer
                    cell.preferredStyle = .wheels
                    cell.setGeneric(Date(
                        timeIntervalSinceReferenceDate: timeInterval))
                    cell.setGeneric { (newValue: Date) in
                        self._taskAttributes[index] = .duration(
                            timeInterval:
                                newValue.timeIntervalSinceReferenceDate)
                        tableView.reloadData()
                    }
                    return cell
                default:
                    preconditionFailure()
                }
            case .fixedDate(let date):
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "DateField",
                        for: indexPath) as! DateFieldPageTableViewCell
                    cell.title = "Fixed Date"
                    cell.label = "Fixed Date"
                    cell.mode = .dateAndTime
                    cell.preferredStyle = .wheels
                    cell.setGeneric(date)
                    cell.setGeneric { (newValue: Date) in
                        self._taskAttributes[index] = .fixedDate(at: newValue)
                        tableView.reloadData()
                    }
                    return cell
                default:
                    preconditionFailure()
                }
            case .priority(let priorityIndex):
                switch indexPath.row {
                case 0:
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: "SelectionField",
                        for: indexPath) as! SelectionFieldPageTableViewCell
                    cell.selections = [
                        .init(rows: [
                            .value(label: "Low"),
                            .value(label: "High"),
                            .value(label: "Highest"),
                        ])
                    ]
                    cell.title = "Priority"
                    cell.label = "Priority"
                    cell.setGeneric(IndexPath(row: priorityIndex, section: 0))
                    cell.setGeneric { (newValue: IndexPath) in
                        self._taskAttributes[index] = .priority(index: newValue.row)
                        tableView.reloadData()
                    }
                    return cell
                default:
                    preconditionFailure()
                }
            }
        case self._taskAttributes.count + 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PlainSelectionFieldButton",
                    for: indexPath) as! SelectionFieldPageTableViewCell
                let selections: [
                    (String, () -> TaskAttributeDescription)
                ] = .build {
                    if !self._taskAttributes.contains(where: {
                        switch $0 {
                        case .duration: true
                        default: false
                        }
                    }) {
                        ("Lasts for an hour", {
                            TaskAttributeDescription.duration(
                                timeInterval: 3600.0) })
                        ("Lasts for half an hour", {
                            TaskAttributeDescription.duration(
                                timeInterval: 1800.0) })
                    }
                    if !self._taskAttributes.contains(where: {
                        switch $0 {
                        case .fixedDate: true
                        default: false
                        }
                    }) {
                        ("Set tomorrow at " +
                        Date.now.formatted(date: .omitted, time: .shortened), {
                            TaskAttributeDescription.fixedDate(at:
                                Date.now.advanced(by: 60 * 60 * 24)) })
                    }
                    if !self._taskAttributes.contains(where: {
                        switch $0 {
                        case .priority: true
                        default: false
                        }
                    }) {
                        ("Set priority", {
                            TaskAttributeDescription.priority(index: 0) })
                        ("Set high priority", {
                            TaskAttributeDescription.priority(index: 1) })
                        ("Set highest priority", {
                            TaskAttributeDescription.priority(index: 2) })
                    }
                }
                cell.selections = [
                    .init(rows: selections.map { .value(label: $0.0) })
                ]
                cell.title = "Add Attribute"
                cell.label = "Add Attribute"
                cell.setGeneric { (newValue: IndexPath) in
                    self._taskAttributes.append(selections[newValue.row].1())
                    tableView.reloadData()
                }
                return cell
            default:
                preconditionFailure()
            }
        case self._taskAttributes.count + 2:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "DestructiveButton",
                    for: indexPath) as! LabeledTableViewCell
                cell.label = "Delete Task"
                return cell
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            return nil
        case 1..<(self._taskAttributes.count + 1):
            let index = indexPath.section - 1
            switch self._taskAttributes[index] {
            case .duration,
                .fixedDate,
                .priority:
                if indexPath.row != 0 {
                    return nil
                }
                return .init(actions: [
                    .init(
                        style: .destructive,
                        title: "Delete") { _, _, completion in
                            self._taskAttributes.remove(at: index)
                            completion(true)
                        }
                ])
            }
        case self._taskAttributes.count + 1:
            switch indexPath.row {
            case 0:
                return nil
            default:
                preconditionFailure()
            }
        case self._taskAttributes.count + 2:
            switch indexPath.row {
            case 0:
                return nil
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                break
            case 1:
                let cell = tableView.cellForRow(at: indexPath)
                    as! TextFieldPageTableViewCell
                self.navigationController!.pushViewController(
                    cell.instantiatePageView(),
                    animated: true)
                break
            default:
                preconditionFailure()
            }
        case 1..<(self._taskAttributes.count + 1):
            let index = indexPath.section - 1
            switch self._taskAttributes[index] {
            case .duration:
                switch indexPath.row {
                case 0:
                    let cell = tableView.cellForRow(at: indexPath)
                        as! DateFieldPageTableViewCell
                    self.navigationController!.pushViewController(
                        cell.instantiatePageView(),
                        animated: true)
                default:
                    preconditionFailure()
                }
            case .fixedDate:
                switch indexPath.row {
                case 0:
                    let cell = tableView.cellForRow(at: indexPath)
                        as! DateFieldPageTableViewCell
                    self.navigationController!.pushViewController(
                        cell.instantiatePageView(),
                        animated: true)
                default:
                    preconditionFailure()
                }
            case .priority:
                switch indexPath.row {
                case 0:
                    let cell = tableView.cellForRow(at: indexPath)
                        as! SelectionFieldPageTableViewCell
                    self.navigationController!.pushViewController(
                        cell.instantiatePageView(),
                        animated: true)
                default:
                    preconditionFailure()
                }
            }
        case self._taskAttributes.count + 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.cellForRow(at: indexPath)
                    as! SelectionFieldPageTableViewCell
                self.navigationController!.pushViewController(
                    cell.instantiatePageView(),
                    animated: true)
            default:
                preconditionFailure()
            }
        case self._taskAttributes.count + 2:
            switch indexPath.row {
            case 0:
                let alert = UIAlertController(
                    title: "Confimation",
                    message:
                        "Delete '\(self._taskTitle)'?",
                    preferredStyle: .alert)
                alert.addAction(.init(
                    title: "Cancel",
                    style: .cancel))
                alert.addAction(.init(
                    title: "Delete",
                    style: .destructive) { _ in
                        DispatchQueue.main.schedule {
                            for listener in self._deleteListeners {
                                listener(())
                            }
                            self.navigationController!.popToBeforeViewController(
                                self,
                                animated: true,
                                orDismiss: true)
                        }
                    })
                self.present(alert, animated: true)
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
}
