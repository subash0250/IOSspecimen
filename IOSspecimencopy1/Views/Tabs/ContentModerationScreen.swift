//
//  ContentModerationScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-25.
//

import SwiftUI
import FirebaseDatabase

struct ContentModerationScreen: View {
    @State private var flaggedPosts: [FlaggedPost] = []

    private let flaggedPostsRef = Database.database().reference().child("flaggedPosts")
    private let usersRef = Database.database().reference().child("users")

    var body: some View {
        NavigationView {
            List(flaggedPosts) { flaggedPost in
                VStack(alignment: .leading) {
                    Text("Flagged By: \(flaggedPost.flaggedBy)")
                    Text("Reason: \(flaggedPost.reason)")
                    Text("Timestamp: \(flaggedPost.timestamp, formatter: dateFormatter)")
                    HStack {
                        Button(action: {
                            deleteFlaggedPost(flaggedPost.flaggedPostID)
                        }) {
                            Text("Delete Post")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            verifyFlaggedPost(flaggedPost.flaggedPostID)
                        }) {
                            Text("Verified Post")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.vertical, 4)
            }
            .navigationTitle("Content Moderation")
            .onAppear {
                fetchFlaggedPosts()
            }
        }
    }

    private func fetchFlaggedPosts() {
        flaggedPostsRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let data = snapshot.value as? [String: Any] else {
                print("No flagged posts exist.")
                return
            }

            var posts: [FlaggedPost] = []

            let group = DispatchGroup()
            for (key, value) in data {
                guard let valueDict = value as? [String: Any],
                      let flaggedByID = valueDict["flaggedBy"] as? String,
                      let reason = valueDict["reason"] as? String else { continue }

                group.enter()
                fetchUserName(userID: flaggedByID) { userName in
                    let timestampString = valueDict["timestamp"] as? String ?? ""
                    let timestamp = DateFormatter().date(from: timestampString) ?? Date()

                    let flaggedPost = FlaggedPost(flaggedPostID: key, flaggedBy: userName, reason: reason, timestamp: timestamp)
                    posts.append(flaggedPost)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.flaggedPosts = posts
            }
        }
    }

    private func fetchUserName(userID: String, completion: @escaping (String) -> Void) {
        usersRef.child(userID).observeSingleEvent(of: .value) { userSnapshot in
            if userSnapshot.exists(), let userData = userSnapshot.value as? [String: Any] {
                completion(userData["userName"] as? String ?? "Unknown User")
            } else {
                completion("Unknown User")
            }
        }
    }

    private func deleteFlaggedPost(_ flaggedPostID: String) {
        flaggedPostsRef.child(flaggedPostID).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String: Any], let postID = data["postID"] as? String else {
                print("Flagged post not found.")
                return
            }
            flaggedPostsRef.child(flaggedPostID).removeValue { error, _ in
                if let error = error {
                    print("Error deleting flagged post: \(error.localizedDescription)")
                    return
                }
                FirebaseDatabase.database().reference().child("posts").child(postID).removeValue { error, _ in
                    if let error = error {
                        print("Error deleting post: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted post from both tables.")
                        self.fetchFlaggedPosts()
                    }
                }
            }
        }
    }

    private func verifyFlaggedPost(_ flaggedPostID: String) {
        flaggedPostsRef.child(flaggedPostID).removeValue { error, _ in
            if let error = error {
                print("Error verifying flagged post: \(error.localizedDescription)")
                return
            }
            fetchFlaggedPosts()
        }
    }
}

struct FlaggedPost: Identifiable {
    let flaggedPostID: String
    let flaggedBy: String
    let reason: String
    let timestamp: Date
    
    var id: String { flaggedPostID }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

struct ContentModerationScreen_Previews: PreviewProvider {
    static var previews: some View {
        ContentModerationScreen()
    }
}
