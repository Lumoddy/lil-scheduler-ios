//
//  CalenderDay.swift
//  Lil' Scheduler
//
//  Created by 13878 on 23/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

public class TaskListScreenView : UITableViewController {
    
    public var userData: UserData? = nil
    
    public static let VIEW_ID = "TaskList"
    
    public override func viewDidLoad() {

        super.viewDidLoad()
        
        super.tableView.dataSource = self;
        super.tableView.delegate = self;
        
        if self.userData == nil {
            if let cloudData = UserData.cloudData {
                self.userData = cloudData
            }
            else {
                UserData.cloudGet {
                    switch Result($0, or: $1) {
                    case .success(let cloudData):
                        DispatchQueue.main.async {
                            self.userData = cloudData
                            self.tableView.reloadData()
                        }
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
                }
            }
        }
    }
    
    @IBAction private func doCreateNewTask() {
        
        let newController = storyboard!.instantiateViewController(
            withIdentifier: TaskDetailsScreenView.VIEW_ID) as! TaskDetailsScreenView
        newController.send(boxed: userData!)
        newController.send(boxed: CalendarTask(
            title: "New Task",
            description: "",
            color: RGB.white))
        newController.listenFor(boxed: { result in
            switch result {
            case let task as CalendarTask:
                do {
                    self.userData!.tasks.append(task)
                    self.tableView.reloadData()
                    try UserData.cloudSet(self.userData!)
                }
                catch {
                    print(error)
                }
                break
            default:
                break
            }
        })
        super.navigationController!.pushViewController(
            newController,
            animated: true)
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let userData = userData {
            segue.destination.sendIfReceiver(value: userData)
        }
        
        segue.destination.listenIfResponderFor { (result: Any?) in
            
            if result is FirebaseAuth.User {
                UserData.cloudGet {
                    switch Result($0, or: $1) {
                    case .success(let cloudData):
                        DispatchQueue.main.async {
                            self.userData = cloudData
                            self.tableView.reloadData()
                        }
                        break
                    case .failure(let error):
                        print(error)
                        break
                    }
                }
            }
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(
                style: .destructive,
                title: "Delete Task",
                handler: { action, view, completion in
                    do {
                        self.userData!.tasks.remove(at: indexPath.row)
                        try UserData.cloudSet(self.userData!) {
                            guard let error = $0 else { return }
                            print(error)
                            DispatchQueue.main.async {
                                self.userData = UserData.cloudData?.clone()
                                self.tableView.reloadData()
                            }
                        }
                    }
                    catch {
                        print(error)
                        self.userData = UserData.cloudData?.clone()
                        self.tableView.reloadData()
                    }
                    
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                })
        ])
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            guard let userData = self.userData else { return 0 }
            return userData.tasks.count

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
            
            guard
                let userData = self.userData,
                let task = userData.tasks[safe: indexPath.row]
            else {
                preconditionFailure("Task index at \(indexPath)")
            }
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "Task",
                for: indexPath) as! TaskListItemView
            
            cell.display(task: task)
            return cell
            
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            
            let newController = storyboard!.instantiateViewController(
                withIdentifier: TaskDetailsScreenView.VIEW_ID) as! TaskDetailsScreenView
            newController.send(boxed: self.userData!)
            newController.send(boxed: self.userData!.tasks[indexPath.row])
            newController.listenFor(boxed: { result in
                switch result {
                case let task as CalendarTask:
                    do {
                        self.userData!.tasks[indexPath.row] = task
                        self.tableView.reloadData()
                        try UserData.cloudSet(self.userData!)
                    }
                    catch {
                        print(error)
                    }
                    break
                case let kept as Bool where kept == false:
                    do {
                        self.userData!.tasks.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        try UserData.cloudSet(self.userData!)
                    }
                    catch {
                        print(error)
                    }
                    break
                default:
                    break
                }
            })
            super.navigationController!.pushViewController(
                newController,
                animated: true)
            
            break
        
        default:
            preconditionFailure()
        }
    }
}
