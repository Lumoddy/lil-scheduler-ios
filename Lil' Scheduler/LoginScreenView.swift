//
//  LoginScreenView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginScreenView : UIViewController {

    public static let VIEW_ID = "LoginScreen"
    
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var disableWhileProcessing: [UIView]?
    
    @IBAction func navigateToCreateAccountScreen() {
        navigationController!.setViewControllers(
            [
                storyboard!.instantiateViewController(
                    withIdentifier: CreateAccountScreenView.VIEW_ID)],
            animated: true)
    }
    
    @IBAction func doLogin() {
        self.disableWhileProcessing?.forEach { view in
            view.trySetEnabled(false)
        }
        FirebaseAuth.Auth.auth().signIn(
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
