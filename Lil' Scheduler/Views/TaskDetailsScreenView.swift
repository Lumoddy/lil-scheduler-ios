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

public class TaskDetailsScreenView
    : UITableViewController,
    UIBoxedValueReceiver,
    UIBoxedValueResponder {
    
    public static let VIEW_ID = "TaskDetails"
    
    public var userData: UserData? = nil
    public var currentTask: CalendarTask? = nil
    
    @IBAction private func doCancel() {
        self.navigationController!.popViewController(animated: true)
    }

    @IBAction private func doDone() {
        self.navigationController!.popViewController(animated: true)
        responseCallback!(currentTask)
    }
    
    @IBAction private func doDelete() {
        self.navigationController!.popViewController(animated: true)
        responseCallback!(false)
    }
    
    public override func viewDidLoad() {

        super.viewDidLoad()
        
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    
    func send(boxed value: Any) -> ()? {
        switch value {
        case let value as UserData:
            userData = value
            return ()
        case let value as CalendarTask:
            currentTask = value
            return ()
        default:
            return nil
        }
    }
    
    private var responseCallback: ((Any?) -> ())? = nil

    func listenFor(boxed callback: @escaping (Any?) -> ()) -> ()? {
        self.responseCallback = callback
        return ()
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
                    self.userData!.tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                })
        ])
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        guard let currentTask = self.currentTask else { return 0 }
        guard let attributes = currentTask.attributes else { return 1 + 1 }
        return 1 + attributes.count + 1
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        if section == 0 {
            return 2
        }
        else if section == 1 + (currentTask!.attributes?.count ?? 0) {
            return 1
        }
        else {
            return 0
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TextField",
                    for: indexPath) as! TextInputTableCell
                cell.labelText = "Title"
                cell.value = currentTask!.title
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "TextField",
                    for: indexPath) as! TextInputTableCell
                cell.labelText = "Description"
                cell.value = currentTask!.description
                return cell
            default:
                preconditionFailure()
            }
        }
        else if indexPath.section == 1 + (currentTask!.attributes?.count ?? 0) {
            return tableView.dequeueReusableCell(
                withIdentifier: "DeleteButton",
                for: indexPath)
        }
        else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TextField",
                for: indexPath) as! TextInputTableCell
            return cell
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let newController = storyboard!.instantiateViewController(
                    withIdentifier: TextInputPage.VIEW_ID) as! TextInputPage
                newController.navigationItem.title = "Title"
                newController.send(value: self.currentTask!.title)
                newController.listenFor(completion: {
                    guard let text = $0 else { return }
                    self.currentTask!.title = text ?? "Unnamed Task"
                    super.tableView.reloadData()
                    super.navigationController!.popToViewController(self, animated: true)
                })
                super.navigationController!.pushViewController(
                    newController,
                    animated: true)
                break
                
            case 1:
                let newController = storyboard!.instantiateViewController(
                    withIdentifier: TextInputPage.VIEW_ID) as! TextInputPage
                newController.navigationItem.title = "Description"
                newController.send(value: self.currentTask!.description)
                newController.listenFor(completion: {
                    guard let text = $0 else { return }
                    self.currentTask!.description = text ?? ""
                    super.tableView.reloadData()
                    super.navigationController!.popToViewController(self, animated: true)
                })
                super.navigationController!.pushViewController(
                    newController,
                    animated: true)
                break

            default:
                preconditionFailure()
            }
        }
        else if indexPath.section == 1 + (currentTask!.attributes?.count ?? 0) {
            responseCallback!(false)
            super.navigationController!.popViewController(animated: true)
        }
        else {
            
        }
    }
}
