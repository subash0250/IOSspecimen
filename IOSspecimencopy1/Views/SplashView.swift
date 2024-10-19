//
//  SplashView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var firebaseService: FirebaseService

    var body: some View {
        VStack {
            Text("Connectify")
                .font(.largeTitle)
                .bold()
            Image("app_logo") // Add your logo here
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if firebaseService.isLoggedIn {
                    // Navigate to Home
                } else {
                    // Navigate to Sign-In
                }
            }
        }
    }
}

