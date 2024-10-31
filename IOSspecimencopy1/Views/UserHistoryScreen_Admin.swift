//
//  UserHistoryScreen_Admin.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-25.
//
import SwiftUI
import FirebaseDatabase



struct UserHistoryView: View {
    let userId: String
    @State private var user: AppUser? // Changed User to AppUser
    @State private var loading = true
    private let usersRef = Database.database().reference().child("users")
    
    var body: some View {
        VStack {
            if loading {
                ProgressView()
            } else if let user = user {
                Text("User: \(user.userName)")
                Text("Role: \(user.userRole)")
                Text("Banned: \(user.isBanned ? "Yes" : "No")")
                Text("Reports: \(user.reports)")
            } else {
                Text("No history available")
            }
        }
        .onAppear(perform: fetchUserHistory)
        .navigationTitle("User History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fetchUserHistory() {
        usersRef.child(userId).getData { error, snapshot in
            if let value = snapshot?.value as? [String: Any] {
                self.user = AppUser(id: userId, data: value) // Changed User to AppUser
            }
            loading = false
        }
    }
}
