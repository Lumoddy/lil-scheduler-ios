//
//  LoginScreenView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth

public class LoginScreenView : UIViewController {

    public static let VIEW_ID = "LoginScreen"
    
    @IBOutlet private var emailField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var disableWhileProcessing: [UIView]?
    
    @IBAction private func navigateToCreateAccountScreen() {
        super.navigationController!.setViewControllers(
            [
                storyboard!.instantiateViewController(
                    withIdentifier: CreateAccountScreenView.VIEW_ID),
            ],
            animated: true)
    }
    
    @IBAction private func doLogin() {
        self.disableWhileProcessing?.forEach { view in
            view.setEnabled(false)
        }
        FirebaseAuth.Auth.auth().signIn(
            withEmail: self.emailField.text ?? "",
            password: self.passwordField.text ?? "",
            completion: either { credential in
                super.navigationController!.dismiss(animated: true)
            } or: { error in
                self.errorLabel.text = error.localizedDescription;
                self.disableWhileProcessing?.forEach { view in
                    view.setEnabled(true)
                }
            })
    }
}
