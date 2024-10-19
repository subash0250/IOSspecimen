//
//  FollowersView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//
import SwiftUI
import Firebase
import FirebaseDatabase


struct FollowersView: View {
    let userId: String
    @State private var followerIds: [String] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading followers...")
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else if followerIds.isEmpty {
                    Text("No followers found.")
                } else {
                    List(followerIds, id: \.self) { followerId in
                        FollowerRow(followerId: followerId)
                    }
                }
            }
            .navigationTitle("Followers")
            .onAppear {
                fetchFollowers()
            }
        }
    }

   
    private func fetchFollowers() {
        let ref = Database.database().reference().child("users").child(userId).child("followers")

        ref.getData { error, snapshot in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                isLoading = false
                return
            }

            if let followers = snapshot?.value as? [String: Any] {
                followerIds = Array(followers.keys)
            } else {
                followerIds = []
            }
            isLoading = false
        }
    }
}


struct FollowerRow: View {
    let followerId: String
    @State private var userName: String = "Loading..."
    @State private var profileImageUrl: String?

    var body: some View {
        HStack {
           
            AsyncImage(url: URL(string: profileImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }

            // Display follower's username
            Text(userName)
                .padding(.leading, 10)
        }
        .onAppear {
            fetchFollowerDetails()
        }
    }

    // Function to fetch follower details like username and profile image from Firebase
    private func fetchFollowerDetails() {
        let ref = Database.database().reference().child("users").child(followerId)

        ref.getData { error, snapshot in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                userName = "Unknown User"
                return
            }

            if let data = snapshot?.value as? [String: Any] {
                userName = data["userName"] as? String ?? "Unknown User"
                profileImageUrl = data["userProfileImage"] as? String
            } else {
                userName = "Unknown User"
            }
        }
    }
}
