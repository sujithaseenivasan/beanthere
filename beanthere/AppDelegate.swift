//
//  AppDelegate.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 2/27/25.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let backButtonAppearance = UIBarButtonItem.appearance()
        backButtonAppearance.setTitleTextAttributes([
            .foregroundColor: UIColor(named: "TextPrimary")!,
            .font: UIFont(name: "Lora-Medium", size: 16)!
        ], for: .normal)
        UINavigationBar.appearance().tintColor = UIColor(named: "TextPrimary")
        
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkModeEnabled")
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        overrideUserInterfaceStyleForAllWindows(style: style)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

