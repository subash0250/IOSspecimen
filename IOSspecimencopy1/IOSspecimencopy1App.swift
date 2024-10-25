//
//  IOSspecimencopy1App.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI

import Firebase

@main


struct IOSspecimencopy1App: App {
  
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
