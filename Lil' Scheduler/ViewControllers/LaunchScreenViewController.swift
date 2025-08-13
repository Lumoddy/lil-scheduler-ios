//
//  LaunchScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 13/8/2025.
//

import UIKit
import FirebaseAuth

public class LaunchScreenViewController : UIViewController {
    
    public override func viewDidLoad() {
        let loginPair = self.storyboard!.instantiateLoginPair()
        var loggedIn = false
        loginPair.setGeneric { (_: User) in
            loggedIn = true
        }
        showLoginPair()
        func showLoginPair() {
            self.present(loginPair, animated: true)
            Task { // I hate Xcode
                while self.presentedViewController != nil {
                    try? await Task.sleep(for: .seconds(0.5))
                }
                if loggedIn {
                    DispatchQueue.main.schedule {
                        self.navigationController!.setViewControllers(
                            [
                                self.storyboard!.instantiateViewController(
                                    withIdentifier: "AppRoot")
                            ],
                            animated: true)
                    }
                }
                else {
                    DispatchQueue.main.schedule(showLoginPair)
                }
            }
        }
    }
}
