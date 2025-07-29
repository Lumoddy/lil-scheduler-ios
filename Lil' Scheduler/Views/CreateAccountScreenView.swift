//
//  LoginScreenView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth

public class CreateAccountScreenView : UIViewController {

    public static let VIEW_ID = "CreateAccountScreen"
    
    @IBOutlet private var emailField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var disableWhileProcessing: [UIView]?
    
    @IBAction private func navigateToLoginScreen(_ sender: Any) {
        navigationController!.setViewControllers(
            [
                storyboard!.instantiateViewController(
                    withIdentifier: LoginScreenView.VIEW_ID),
            ],
            animated: true)
    }
    
    @IBAction private func doCreateAccount() {
        self.disableWhileProcessing?.forEach { view in
            view.setEnabled(false)
        }
        FirebaseAuth.Auth.auth().createUser(
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
