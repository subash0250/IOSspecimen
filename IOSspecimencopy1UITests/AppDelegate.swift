//
//  AppDelegate.swift
//  IOSspecimencopy1UITests
//
//  Created by Subash Gaddam on 2024-10-13.
//

import Foundation


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
