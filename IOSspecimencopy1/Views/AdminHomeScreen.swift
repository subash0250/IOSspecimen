//
//  AdminHomeScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-25.
//


import SwiftUI

struct AdminHomeScreen: View {
    @State private var selectedIndex = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            
            AdminHomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            UserManagementTab()
                .tabItem {
                    Image(systemName: "gear")
                    Text("UserManager")
                }
                .tag(1)
            
            ContentModerationScreen()
                .tabItem {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Reports")
                }
                .tag(2)
            
            ProfileScreen()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.white)
        .background(Color.black) 
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.black
        }
    }
}

struct AdminHomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeScreen()
    }
}
