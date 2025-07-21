//
//  AppDelegate.swift
//  Lil' Scheduler
//
//  Created by 13878 on 21/7/2025.
//

import UIKit
import FirebaseCore
@main

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions
            : [UIApplication.LaunchOptionsKey: Any]?)
        -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions)
        -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
        -> () {
        
    }
}
