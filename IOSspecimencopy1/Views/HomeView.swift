//
//  HomeView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            FollowersScreen()
                .tabItem {
                    Label("Followers", systemImage: "person.2.fill")
                }

            PostScreen()
                .tabItem {
                    Label("Post", systemImage: "plus.circle.fill")
                }

            ProfileScreen()  
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

