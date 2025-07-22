//
//  LoginScreenView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth

class CreateAccountScreenView : UIViewController {

    public static let VIEW_ID = "CreateAccountScreen"
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var disableWhileProcessing: [UIView]?
    
    @IBAction func navigateToLoginScreen(_ sender: Any) {
        navigationController!.setViewControllers(
            [
                storyboard!.instantiateViewController(
                    withIdentifier: LoginScreenView.VIEW_ID),
            ],
            animated: true)
    }
    
    @IBAction func doCreateAccount() {
        self.disableWhileProcessing?.forEach { view in
            view.trySetEnabled(false)
        }
        FirebaseAuth.Auth.auth().createUser(
            withEmail: self.emailField.text ?? "",
            password: self.passwordField.text ?? "",
            completion: either { credential in
                print("Logged in")
            } or: { error in
                self.errorLabel.text = error.localizedDescription;
                self.disableWhileProcessing?.forEach { view in
                    view.trySetEnabled(true)
                }
            })
    }
}
