//
//  LoginScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 7/8/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// ### Responds:
/// * `"authenticated"` or nil : `AuthDataResult` and `User`
/// * `"login"` : `AuthDataResult` and `User`
/// * `"createAccount"` : `AuthDataResult` and `User`
/// ### Sends Below:
/// * `"authenticated"` : `AuthDataResult` and `User` and `()`
/// * `"login"` : `AuthDataResult` and `User` and `()`
/// * `"createAccount"` : `AuthDataResult` and `User` and `()`
public class LoginScreenViewController
    : UITableViewController,
    ValueReceiver,
    ValueResponder {
    
    private static let _authenticatedLabel = "authenticated"
    private static let _loginLabel = "login"
    private static let _createAccountLabel = "createAccount"
    
    @IBOutlet private var _emailField: UITextField?
    @IBOutlet private var _passwordField: UITextField?
    @IBOutlet private var _errorLabel: UILabel?
    @IBOutlet private var _activityIndicator: UIActivityIndicatorView?
    
    @IBAction private func _doLogin() {
        self.view.isUserInteractionEnabled = false
        self._activityIndicator?.startAnimating()
        FirebaseAuth.Auth.auth().signIn(
            withEmail: _emailField!.text ?? "",
            password: _passwordField!.text ?? "",
            completion: {
                switch Result($0, or: $1) {
                case .success(let result):
                    for listener in self._authenticatedResultListeners {
                        listener(result)
                    }
                    for listener in self._authenticatedUserListeners {
                        listener(result.user)
                    }
                    for listener in self._loginResultListeners {
                        listener(result)
                    }
                    for listener in self._loginUserListeners {
                        listener(result.user)
                    }
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        result)
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        result.user)
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        ())
                    self.sendBelow(
                        named: LoginScreenViewController._loginLabel,
                        result)
                    self.sendBelow(
                        named: LoginScreenViewController._loginLabel,
                        result.user)
                    self.sendBelow(
                        named: LoginScreenViewController._loginLabel,
                        ())
                    self.navigationController!.popToBeforeViewController(
                        self,
                        animated: true,
                        orDismiss: true)
                    break
                case .failure(let error):
                    self._errorLabel!.text = error.localizedDescription
                    self.view.isUserInteractionEnabled = true
                    break
                }
                self._activityIndicator?.stopAnimating()
            })
    }

    @IBAction private func _doCreateAccount() {
        self.view.isUserInteractionEnabled = false
        self._activityIndicator?.startAnimating()
        FirebaseAuth.Auth.auth().signIn(
            withEmail: _emailField!.text ?? "",
            password: _passwordField!.text ?? "",
            completion: {
                switch Result($0, or: $1) {
                case .success(let result):
                    for listener in self._authenticatedResultListeners {
                        listener(result)
                    }
                    for listener in self._authenticatedUserListeners {
                        listener(result.user)
                    }
                    for listener in self._createAccountResultListeners {
                        listener(result)
                    }
                    for listener in self._createAccountUserListeners {
                        listener(result.user)
                    }
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        result)
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        result.user)
                    self.sendBelow(
                        named: LoginScreenViewController._authenticatedLabel,
                        ())
                    self.sendBelow(
                        named: LoginScreenViewController._createAccountLabel,
                        result)
                    self.sendBelow(
                        named: LoginScreenViewController._createAccountLabel,
                        result.user)
                    self.sendBelow(
                        named: LoginScreenViewController._createAccountLabel,
                        ())
                    self.navigationController!.popToBeforeViewController(
                        self,
                        animated: true,
                        orDismiss: true)
                    break
                case .failure(let error):
                    self._errorLabel!.text = error.localizedDescription
                    self.view.isUserInteractionEnabled = true
                    break
                }
                self._activityIndicator?.stopAnimating()
            })
    }
    
    @IBAction private func _loginInstead() {
        let screen = storyboard!.instantiateLoginScreenViewController()
        screen._authenticatedResultListeners = self._authenticatedResultListeners
        screen._authenticatedUserListeners = self._authenticatedUserListeners
        screen._loginResultListeners = self._loginResultListeners
        screen._loginUserListeners = self._loginUserListeners
        screen._createAccountResultListeners = self._createAccountResultListeners
        screen._createAccountUserListeners = self._createAccountUserListeners
        self.navigationController!.replaceTopViewController(
            screen,
            animated: true)
    }
    
    @IBAction private func _createAccountInstead() {
        let screen = storyboard!.instantiateCreateAccountScreenViewController()
        screen._authenticatedResultListeners = self._authenticatedResultListeners
        screen._authenticatedUserListeners = self._authenticatedUserListeners
        screen._loginResultListeners = self._loginResultListeners
        screen._loginUserListeners = self._loginUserListeners
        screen._createAccountResultListeners = self._createAccountResultListeners
        screen._createAccountUserListeners = self._createAccountUserListeners
        self.navigationController!.replaceTopViewController(
            screen,
            animated: true)
    }
    
    private var _authenticatedResultListeners: [(AuthDataResult) -> ()] = []
    private var _authenticatedUserListeners: [(User) -> ()] = []
    private var _loginResultListeners: [(AuthDataResult) -> ()] = []
    private var _loginUserListeners: [(User) -> ()] = []
    private var _createAccountResultListeners: [(AuthDataResult) -> ()] = []
    private var _createAccountUserListeners: [(User) -> ()] = []
    
    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        case ("error", let value as String?):
            self._errorLabel?.text = value
            return ()
        default:
            return nil
        }
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        case (
            LoginScreenViewController._authenticatedLabel,
            let listener as (AuthDataResult) -> ()
        ),
            (nil, let listener as (AuthDataResult) -> ()):
            _authenticatedResultListeners.append(listener)
            return ()
        case (
            LoginScreenViewController._authenticatedLabel,
            let listener as (User) -> ()
        ),
            (nil, let listener as (User) -> ()):
            _authenticatedUserListeners.append(listener)
            return ()
        case (
            LoginScreenViewController._loginLabel,
            let listener as (AuthDataResult) -> ()
        ),
            (nil, let listener as (AuthDataResult) -> ()):
            _loginResultListeners.append(listener)
            return ()
        case (
            LoginScreenViewController._loginLabel,
            let listener as (User) -> ()
        ),
            (nil, let listener as (User) -> ()):
            _loginUserListeners.append(listener)
            return ()
        case (
            LoginScreenViewController._createAccountLabel,
            let listener as (AuthDataResult) -> ()
        ),
            (nil, let listener as (AuthDataResult) -> ()):
            _createAccountResultListeners.append(listener)
            return ()
        case (
            LoginScreenViewController._createAccountLabel,
            let listener as (User) -> ()
        ),
            (nil, let listener as (User) -> ()):
            _createAccountUserListeners.append(listener)
            return ()
        default:
            return nil
        }
    }
}

extension UIStoryboard {
    
    public func instantiateLoginScreenViewController(
    ) -> LoginScreenViewController {
        return self.instantiateViewController(
            withIdentifier: "LoginScreen")
            as! LoginScreenViewController
    }
    
    public func instantiateCreateAccountScreenViewController(
    ) -> LoginScreenViewController {
        return self.instantiateViewController(
            withIdentifier: "CreateAccountScreen")
            as! LoginScreenViewController
    }
}
