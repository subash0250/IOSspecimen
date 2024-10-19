//
//  CommentScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-15.
//
import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct CommentScreen: View {
    let postId: String
    @State private var newComment = ""
    @State private var comments: [Comment] = []
    private var dbRef = Database.database().reference()

    
    init(postId: String) {
           self.postId = postId
       }

    
    var body: some View {
        VStack {
            List(comments) { comment in
                HStack(alignment: .top) {
                    AsyncImage(url: URL(string: comment.userProfileImage)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle().fill(Color.gray).frame(width: 40, height: 40)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(comment.userName).font(.headline)
                        Text(comment.text).font(.body)
                        Text(comment.timestampFormatted)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            HStack {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 44)

                Button(action: postComment) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Comments")
        .onAppear {
            fetchComments()
        }
    }

    // Fetch Comments in Real-Time
    func fetchComments() {
        let commentsRef = dbRef.child("posts").child(postId).child("comments")

        commentsRef.observe(.value) { snapshot in
            var newComments: [Comment] = []

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let text = dict["commentText"] as? String,
                   let _userId = dict["userId"] as? String,
                   let timestamp = dict["timestamp"] as? TimeInterval {

                    let userName = dict["userName"] as? String ?? "Anonymous"
                    let userProfileImage = dict["userProfileImage"] as? String ?? ""

                    let comment = Comment(
                        id: childSnapshot.key,
                        userName: userName,
                        userProfileImage: userProfileImage,
                        text: text,
                        timestamp: Date(timeIntervalSince1970: timestamp / 1000)
                    )
                    newComments.append(comment)
                }
            }

            // Update the comments list in UI
            self.comments = newComments
        }
    }

    // Post a new comment
    func postComment() {
        guard !newComment.isEmpty, let userId = Auth.auth().currentUser?.uid else { return }

        let commentsRef = dbRef.child("posts").child(postId).child("comments").childByAutoId()
        let commentData: [String: Any] = [
            "commentText": newComment,
            "userId": userId,
            "userName": Auth.auth().currentUser?.displayName ?? "User",
            "userProfileImage": Auth.auth().currentUser?.photoURL?.absoluteString ?? "",
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]

        commentsRef.setValue(commentData) { error, _ in
            if let error = error {
                print("Failed to post comment: \(error.localizedDescription)")
            } else {
                self.newComment = ""
            }
        }
    }
}

// Comment Model
struct Comment: Identifiable {
    let id: String
    let userName: String
    let userProfileImage: String
    let text: String
    let timestamp: Date

    var timestampFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        return formatter.string(from: timestamp)
    }
}
