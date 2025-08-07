//
//  LoginScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 7/8/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

public class LoginScreenViewController : UIViewController {
    
    @IBOutlet private var _emailField: UITextField?
    @IBOutlet private var _passwordField: UITextField?
    @IBOutlet private var _errorLabel: UILabel? = nil
    
    @IBAction private func _doLogin() {
        self.view.isUserInteractionEnabled = false
        FirebaseAuth.Auth.auth().signIn(
            withEmail: _emailField.text ?? "",
            password: _passwordField.text ?? "",
            completion: {
                switch Result($0, or: $1) {
                case .success(let result):
                    self.navigationController!.popToBeforeViewController(
                        self,
                        animated: true,
                        orDismiss: true)
                    break
                case .failure(let error):
                    self._errorLabel.text = error.localizedDescription
                    self.view.isUserInteractionEnabled = true
                    break
                }
            })
    }

    @IBAction private func _doCreateAccount() {
        self.view.isUserInteractionEnabled = false
        FirebaseAuth.Auth.auth().signIn(
            withEmail: _emailField.text ?? "",
            password: _passwordField.text ?? "",
            completion: {
                switch Result($0, or: $1) {
                case .success(let result):
                    self.navigationController!.popToBeforeViewController(
                        self,
                        animated: true,
                        orDismiss: true)
                    break
                case .failure(let error):
                    self._errorLabel.text = error.localizedDescription
                    self.view.isUserInteractionEnabled = true
                    break
                }
            })
    }
    
    @IBAction private func _loginInstead() {
        self.navigationController!.replaceTopViewController(
            storyboard!.instantiateViewController(
                withIdentifier: "LoginScreen"),
            animated: true)
    }
    
    @IBAction private func _createAccountInstead() {
        self.navigationController!.replaceTopViewController(
            storyboard!.instantiateViewController(
                withIdentifier: "CreateAccountScreen"),
            animated: true)
    }
}
