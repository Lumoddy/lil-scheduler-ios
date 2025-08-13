//
//  LoginScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 7/8/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// ### Generic Gets:
/// * `"authenticated"` or nil : `AuthDataResult` or `User`
/// * `"login"` : `AuthDataResult` or `User`
/// * `"createAccount"` : `AuthDataResult` or `User`
///
/// ### Generic Sets:
/// * `"authenticated"` : `AuthDataResult` or `User` or
///     `(AuthDataResult) -> ()` or `(User) -> ()`
/// * `"login"` : `AuthDataResult` or `User` or
///     `(AuthDataResult) -> ()` or `(User) -> ()`
/// * `"createAccount"` : `AuthDataResult` or `User` or
///     `(AuthDataResult) -> ()` or `(User) -> ()`
public class LoginScreenViewController
    : UITableViewController,
    GenericValueInterface {
    
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
        let screen = self.storyboard!.instantiateViewController(
            withIdentifier: "LoginScreen")
            as! LoginScreenViewController
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
        let screen = self.storyboard!.instantiateViewController(
            withIdentifier: "CreateAccountScreen")
            as! LoginScreenViewController
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
    
    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        switch (label, value) {
        case ("error", let value as String?):
            self._errorLabel?.text = value
            return .effect
        case ("authenticated", let listener as (AuthDataResult) -> ()),
            (nil, let listener as (AuthDataResult) -> ()):
            _authenticatedResultListeners.append(listener)
            return .caught
        case ("authenticated", let listener as (User) -> ()),
            (nil, let listener as (User) -> ()):
            _authenticatedUserListeners.append(listener)
            return .caught
        case ("login", let listener as (AuthDataResult) -> ()),
            (nil, let listener as (AuthDataResult) -> ()):
            _loginResultListeners.append(listener)
            return .caught
        case ("login", let listener as (User) -> ()),
            (nil, let listener as (User) -> ()):
            _loginUserListeners.append(listener)
            return .caught
        case ("createAccount", let listener as (AuthDataResult) -> ()),
            (nil, let listener as (AuthDataResult) -> ()):
            _createAccountResultListeners.append(listener)
            return .caught
        case ("createAccount", let listener as (User) -> ()),
            (nil, let listener as (User) -> ()):
            _createAccountUserListeners.append(listener)
            return .caught
        default:
            return .noEffect
        }
    }
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        return nil
    }
}

extension UIStoryboard {
    
    public func instantiateLoginPair(
    ) -> UIValueRelayNavigationController {
        return self.instantiateViewController(
            withIdentifier: "LoginPair")
        as! UIValueRelayNavigationController
    }
}
