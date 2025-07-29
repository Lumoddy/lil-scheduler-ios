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
    
    @IBOutlet private var taskListContainer: UIView!
    
    public override func viewDidLoad() {
                
        let auth = Auth.auth()
        guard let currentUser = auth.currentUser else { return }
        
        let firestore = Firestore.firestore()
        let userDocumentReference = firestore.document("users/\(currentUser.uid)")
        
        when(userDocumentReference.getDocument) { document in
            DispatchQueue.main.async {
                
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
                
                self.taskListContainer.subviews.forEach { $0.removeFromSuperview() }
                
                userData.tasks.forEach { task in
                    let view = CalenderTaskView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    self.taskListContainer.addSubview(view)
                    view.set(to: task)
                }
            }
        }
    }
}
