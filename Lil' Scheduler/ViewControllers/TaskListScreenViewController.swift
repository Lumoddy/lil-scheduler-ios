//
//  TaskListScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 12/8/2025.
//

import UIKit
import FirebaseAuth

public class TaskListScreenViewController
    : UITableViewController,
    GenericValueInterface {
    
    public override func viewDidLoad() {
        let auth = Auth.auth()
        if let _ = auth.currentUser {
            tryDownload()
            func tryDownload() {
                UserData.cloudGet {
                    switch Result($0, or: $1) {
                    case .success:
                        DispatchQueue.main.schedule {
                            self.tableView.reloadData()
                        }
                        break
                    case .failure:
                        let alert = UIAlertController(
                            title: "Cloud Error",
                            message:
                                "Failed to load from the cloud.",
                            preferredStyle: .alert)
                        alert.addAction(.init(
                            title: "Retry",
                            style: .default) { _ in
                                tryDownload()
                            })
                        alert.addAction(.init(
                            title: "Ignore",
                            style: .cancel))
                        self.present(alert, animated: true)
                        break
                    }
                }
            }
        }
    }
    
    @IBAction private func _createNewTask() {
        let screen = self.storyboard!.instantiateViewController(
            withIdentifier: "TaskDetailScreen")
            as! TaskDetailScreenViewController
        screen.setGeneric { (task: TaskDescription) in
            UserData.localData.tasks.append(task)
            self.tableView.reloadData()
            tryUpload()
            func tryUpload() {
                do {
                    try UserData.cloudSet(
                        UserData.localData) { error in
                        if error == nil {
                            return
                        }
                        let alert = UIAlertController(
                            title: "Cloud Error",
                            message:
                                "Failed to save to the cloud.",
                            preferredStyle: .alert)
                        alert.addAction(.init(
                            title: "Retry",
                            style: .default) { _ in
                                tryUpload()
                            })
                        alert.addAction(.init(
                            title: "Ignore",
                            style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
                catch {
                    let alert = UIAlertController(
                        title: "Cloud Error",
                        message:
                            "Failed to save to the cloud.",
                        preferredStyle: .alert)
                    alert.addAction(.init(
                        title: "Ok",
                        style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
        self.navigationController!.pushViewController(screen, animated: true)
    }
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        default:
            return nil
        }
    }

    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        switch (label, value) {
        default:
            return .noEffect
        }
    }
    
    public override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1
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
    
    public override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            return .init(actions: [
                .init(
                    style: .destructive,
                    title: "Delete") { _, _, completion in
                    if UserData.localData.tasks.remove(
                        safelyAt: indexPath.row) == nil {
                        completion(false)
                    }
                    else {
                        completion(true)
                        if Auth.auth().currentUser != nil {
                            tableView.reloadData()
                            tryUpload()
                            func tryUpload() {
                                do {
                                    try UserData.cloudSet(
                                        UserData.localData) { error in
                                        if error == nil {
                                            return
                                        }
                                        let alert = UIAlertController(
                                            title: "Cloud Error",
                                            message:
                                                "Failed to save to the cloud.",
                                            preferredStyle: .alert)
                                        alert.addAction(.init(
                                            title: "Retry",
                                            style: .default) { _ in
                                                tryUpload()
                                            })
                                        alert.addAction(.init(
                                            title: "Ignore",
                                            style: .cancel))
                                        self.present(alert, animated: true)
                                    }
                                }
                                catch {
                                    let alert = UIAlertController(
                                        title: "Cloud Error",
                                        message:
                                            "Failed to save to the cloud.",
                                        preferredStyle: .alert)
                                    alert.addAction(.init(
                                        title: "Ok",
                                        style: .cancel))
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }
            ])
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        switch indexPath.section {
        case 0:
            let index = indexPath.row
            let screen = self.storyboard!.instantiateViewController(
                withIdentifier: "TaskDetailScreen")
                as! TaskDetailScreenViewController
            screen.setGeneric(UserData.localData.tasks[index])
            screen.setGeneric { (task: TaskDescription) in
                UserData.localData.tasks[index] = task
                self.tableView.reloadData()
                tryUpload()
                func tryUpload() {
                    do {
                        try UserData.cloudSet(
                            UserData.localData) { error in
                            if error == nil {
                                return
                            }
                            let alert = UIAlertController(
                                title: "Cloud Error",
                                message:
                                    "Failed to save to the cloud.",
                                preferredStyle: .alert)
                            alert.addAction(.init(
                                title: "Retry",
                                style: .default) { _ in
                                    tryUpload()
                                })
                            alert.addAction(.init(
                                title: "Ignore",
                                style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                    catch {
                        let alert = UIAlertController(
                            title: "Cloud Error",
                            message:
                                "Failed to save to the cloud.",
                            preferredStyle: .alert)
                        alert.addAction(.init(
                            title: "Ok",
                            style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            }
            screen.setGeneric(named: "delete") { (_: ()) in
                UserData.localData.tasks.remove(at: index)
                self.tableView.reloadData()
                tryUpload()
                func tryUpload() {
                    do {
                        try UserData.cloudSet(
                            UserData.localData) { error in
                            if error == nil {
                                return
                            }
                            let alert = UIAlertController(
                                title: "Cloud Error",
                                message:
                                    "Failed to save to the cloud.",
                                preferredStyle: .alert)
                            alert.addAction(.init(
                                title: "Retry",
                                style: .default) { _ in
                                    tryUpload()
                                })
                            alert.addAction(.init(
                                title: "Ignore",
                                style: .cancel))
                            self.present(alert, animated: true)
                        }
                    }
                    catch {
                        let alert = UIAlertController(
                            title: "Cloud Error",
                            message:
                                "Failed to save to the cloud.",
                            preferredStyle: .alert)
                        alert.addAction(.init(
                            title: "Ok",
                            style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
            }
            self.navigationController!.pushViewController(screen, animated: true)
        default:
            preconditionFailure()
        }
    }
}

public class TaskListTableViewCell
    : UITableViewCell {

    @IBOutlet private var _title: UILabel!
    @IBOutlet private var _description: UILabel!
    @IBOutlet private var _attributeList: UILabel!
    
    public override func prepareForReuse() {
        self.title = nil
        self.descriptionText = nil
        self.attributeList = nil
    }
    
    public var title: String? {
        get { return self._title.text }
        set { self._title.text = newValue }
    }
    
    public var descriptionText: String? {
        get { return self._description.text }
        set { self._description.text = newValue }
    }
    
    public var attributeList: String? {
        get { return self._attributeList.text }
        set { self._attributeList.text = newValue }
    }
}
