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
            Image("logo")
            
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                firebaseService.checkAuthStatus()
            }
        }
        .fullScreenCover(isPresented: $firebaseService.isLoggedIn) {
            HomeView()
        }
        .fullScreenCover(isPresented: .constant(!firebaseService.isLoggedIn)) {
            SignInView()
        }
    }
}

