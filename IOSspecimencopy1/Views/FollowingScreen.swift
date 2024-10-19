//
//  FollowingScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI
import FirebaseDatabase


struct FollowingScreen: View {
    let userId: String
    @State private var followingUsers: [user] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if followingUsers.isEmpty {
                    Text("No following found")
                } else {
                    List(followingUsers) { user in
                        HStack {
                            AsyncImage(url: URL(string: user.profileImage)) { image in
                                image.resizable()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)

                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

                            Text(user.userName)
                        }
                        .onTapGesture {
                            // Navigate to user profile
                            print("Tapped on user: \(user.userName ?? "")")
                        }
                    }
                }
            }
            .navigationTitle("Following")
            .onAppear {
                fetchFollowing()
            }
        }
    }

    private func fetchFollowing() {
          let ref = Database.database().reference()
          ref.child("users/\(userId)/following").observeSingleEvent(of: .value) { snapshot in
              print("Snapshot value: \(snapshot.value ?? "No data")")

              guard let followingData = snapshot.value as? [String: Any] else {
                  self.isLoading = false
                  self.errorMessage = "No following found"
                  return
              }

              let followingIds = Array(followingData.keys)
              fetchUserDetails(for: followingIds)
          } withCancel: { error in
              self.isLoading = false
              self.errorMessage = "Error loading following list"
          }
      }
  
    private func fetchUserDetails(for ids: [String]) {
        let ref = Database.database().reference()
        var users: [user] = []
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            ref.child("users/\(id)").observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any],
                   let uid = id as? String,
                   let userName = userData["userName"] as? String,
                   let profileImage = userData["userProfileImage"] as? String {
                    let user = user(uid: uid, userName: userName, profileImage: profileImage)
                    users.append(user)
                }
                group.leave()
            } withCancel: { error in
                print("Error loading user: \(error.localizedDescription)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.followingUsers = users
            self.isLoading = false
        }
    }

}



struct user: Identifiable, Codable {
    var id: String { uid }
    let uid: String
    let userName: String
    let profileImage: String
}
