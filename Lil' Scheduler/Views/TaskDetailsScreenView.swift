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
    : UIViewController,
    UITableViewDelegate,
    UITableViewDataSource {
    
    public static let VIEW_ID = "TaskDetailsScreen"
    
    @IBOutlet private var taskListContainer: UITableView!
    
    public var userData: UserData? = nil
    public var refreshParentDisplay: (() -> ())? = nil
    
    @IBAction private func doNewTask() {
        super.navigationController!.pushViewController(
            storyboard!.instantiateViewController(
                withIdentifier: TaskListScreenView.VIEW_ID),
            animated: true)
    }
    
    public override func viewDidLoad() {

        super.viewDidLoad()
        
        self.taskListContainer.dataSource = self;
        self.taskListContainer.delegate = self;
        
        if self.userData == nil {
            if let cloudData = UserData.cloudData {
                self.userData = cloudData
            }
            else {
                UserData.cloudGet(completion: either { cloudData in
                    self.userData = cloudData
                }
                or: { error in
                    print(error)
                })
            }
        }
    }
    
    public func tableView(
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
                    self.refreshParentDisplay?()
                })
        ])
    }
    
    public func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        switch indexPath.section {
        case 0:
            switch editingStyle {
            case .delete:

                let index = indexPath.row
                
                let auth = Auth.auth()
                
                let firestore = Firestore.firestore()
                let userDocumentReference = firestore.document(
                    "users/\(auth.currentUser!.uid)")
                
                do {
                    try userDocumentReference.setData(
                        from: userData!,
                        completion: either { error in
                            print(error)
                        }
                        or: { })
                }
                catch {
                    print(error)
                }
                
                break

            default:
                break
            }
        default:
            break
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        guard let userData = self.userData else { return 0 }
        return userData.tasks.count
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        
        guard let userData = self.userData,
              let task = userData.tasks[safe: indexPath.row],
              indexPath.section == 0
        else {
            return tableView.dequeueReusableCell(withIdentifier: "invalid", for: indexPath)
        }
        
        configuration.text = task.title
        var secondaryText = task.description
        task.attributes?.forEach { attribute in
            if secondaryText.count > 0 {
                secondaryText += "\n"
            }
            secondaryText += String(describing: attribute)
        }
        configuration.secondaryText = secondaryText
        cell.contentConfiguration = configuration
        return cell
    }
}
