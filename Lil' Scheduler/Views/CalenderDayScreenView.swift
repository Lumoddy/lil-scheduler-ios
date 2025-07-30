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

public class CalenderDayScreenView : UIViewController {
    
    public static let VIEW_ID = "CalendarDayScreen"
    
    @IBOutlet private var taskListContainer: UITableView!
    
    public var userData: UserData? = nil;
    public var cloudUserData: UserData? = nil;
    
    public override func viewDidLoad() {

        super.viewDidLoad()
        
        taskListContainer.dataSource = self;
        taskListContainer.delegate = self;
                
        let auth = Auth.auth()
        guard let currentUser = auth.currentUser else { return }
        
        let firestore = Firestore.firestore()
        let userDocumentReference = firestore.document("users/\(currentUser.uid)")
        
        userDocumentReference.getDocument(completion: either { document in
            
            let userData: UserData
            if document.exists {
                do {
                    userData = try document.data(as: UserData.self)
                }
                catch {
                    print(error)
                    return
                }
            }
            else {
                userData = UserData()
            }
            
            DispatchQueue.main.async {
                self.cloudUserData = userData
                self.userData = userData.clone()
                self.taskListContainer.reloadData()
            }
        }
        or: { error in
            print(error)
        })
    }
}

extension CalenderDayScreenView : UITableViewDelegate {
    
    public func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(
                style: .destructive,
                title: "Delete Task",
                handler: { action, view, completion in
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                })
        ])
    }
    
    public func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        switch editingStyle {
        case .delete:

            let auth = Auth.auth()
            
            let firestore = Firestore.firestore()
            let userDocumentReference = firestore.document("users/\(auth.currentUser!.uid)")
            
            do {
                try userDocumentReference.setData(from: userData!) { error in
                    guard let error = error else { return }
                    print(error)
                    DispatchQueue.main.async {
                        self.userData = self.cloudUserData!.clone()
                    }
                }
                self.userData!.tasks.remove(at: indexPath.row)
            }
            catch {
                print(error)
            }
            
            break;

        default:
            break;
        }
    }
}

extension CalenderDayScreenView : UITableViewDataSource {
    
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
