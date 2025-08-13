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
public class TaskDetailScreenViewController
    : UITableViewController,
      GenericValueInterface {
    
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
            _taskListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
    
    public override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        1
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return UserData.localData.tasks.count
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
                    withIdentifier: "Task",
                    for: indexPath) as! TaskListTableViewCell
                let task = UserData.localData.tasks[indexPath.row]
                cell.title = task.title
                cell.descriptionText = task.descriptionText
                cell.attributeList = task.attributes?
                    .map { $0.description }
                    .joined(separator: "\n")
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Task",
                    for: indexPath) as! TaskListTableViewCell
                let task = UserData.localData.tasks[indexPath.row]
                cell.title = task.title
                cell.descriptionText = task.descriptionText
                cell.attributeList = task.attributes?
                    .map { $0.description }
                    .joined(separator: "\n")
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Task",
                    for: indexPath) as! TaskListTableViewCell
                let task = UserData.localData.tasks[indexPath.row]
                cell.title = task.title
                cell.descriptionText = task.descriptionText
                cell.attributeList = task.attributes?
                    .map { $0.description }
                    .joined(separator: "\n")
                return cell
            }
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            if indexPath.row != 0 {
                return nil
            }
            return .init(actions: [])
        default:
            preconditionFailure()
        }
    }
}
