//
//  IOSspecimencopy1App.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI

import Firebase

@main

//class AppDelegate: NSObject, UIApplicationDelegate {
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//    FirebaseApp.configure()
//    return true
//  }
//}

struct IOSspecimencopy1App: App {
   // @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var firebaseService = FirebaseService()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
               .environmentObject(firebaseService)
        }
    }
}
