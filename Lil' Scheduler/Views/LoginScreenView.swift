//
//  LoginScreenView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 22/7/2025.
//

import UIKit
import Firebase
import FirebaseAuth

public class LoginScreenView : UIViewController, UIValueResponder {

    public static let VIEW_ID = "LoginScreen"
    
    @IBOutlet private var emailField: UITextField!
    @IBOutlet private var passwordField: UITextField!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var disableWhileProcessing: [UIView]?
    
    @IBAction private func navigateToCreateAccountScreen() {
        let newController = storyboard!.instantiateViewController(
            withIdentifier: CreateAccountScreenView.VIEW_ID)
        switch newController {
        case let newController as any UIValueResponder<FirebaseAuth.User>:
            if let responseCallback = responseCallback {
                newController.listenFor(completion: responseCallback)
            }
            break
        case let newController as any UIValueResponder<Any>:
            if let responseCallback = responseCallback {
                newController.listenFor { result in responseCallback(nil) }
            }
            break
        default:
            break
        }
        super.navigationController!.setViewControllers(
            [newController],
            animated: true)
    }
    
    @IBAction private func doLogin() {
        self.disableWhileProcessing?.forEach { view in
            view.setEnabled(false)
        }
        FirebaseAuth.Auth.auth().signIn(
            withEmail: self.emailField.text ?? "",
            password: self.passwordField.text ?? "") {
            switch Result($0, or: $1) {
            case .success(let credential):
                super.navigationController!.dismiss(animated: true)
                self.responseCallback?(credential.user)
                break
            case .failure(let error):
                self.errorLabel.text = error.localizedDescription;
                self.disableWhileProcessing?.forEach { view in
                    view.setEnabled(true)
                }
                break
            }
        }
    }

    typealias Value = FirebaseAuth.User
    private var responseCallback: ((FirebaseAuth.User?) -> ())? = nil

    public func listenFor(
        completion callback: @escaping (FirebaseAuth.User?) -> ()
    ) -> ()? {
        responseCallback = callback
        return ()
    }
}
