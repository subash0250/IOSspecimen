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

