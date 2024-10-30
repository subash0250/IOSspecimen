//
//  ContentView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var firebaseService: FirebaseService

    var body: some View {
           SplashView()
               .fullScreenCover(item: $firebaseService.destination) { destination in
                   switch destination {
                   case .admin:
                       AdminHomeScreen()
                   case .moderator:
                       ModeratorHomeScreen()
                   case .user:
                       HomeView()
                   case .signIn:
                       SignInView()
                   }
               }
       }
}



