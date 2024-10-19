//
//  UserPostsScreen.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-16.
//

import SwiftUI


import Firebase
import FirebaseDatabase
import FirebaseStorage
import PhotosUI

struct UserPostsScreen: View {
    let userId: String
    @State private var userPosts: [[String: Any]] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading posts...")
                } else if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else if userPosts.isEmpty {
                    Text("No posts found.")
                } else {
                    List {
                        ForEach(userPosts.indices, id: \.self) { index in
                            PostRow(post: userPosts[index], onEdit: { post in
                                editPost(postId: post["postId"] as! String, post: post)
                            }, onDelete: { postId in
                                deletePost(postId: postId)
                            })
                        }
                    }
                }
            }
            .navigationTitle("My Posts")
            .onAppear {
                loadUserPosts()
            }
        }
    }

    // Load user's posts from Firebase
    private func loadUserPosts() {
        let ref = Database.database().reference().child("posts")
        ref.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value) { snapshot in
            
            var posts: [[String: Any]] = []

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let post = childSnapshot.value as? [String: Any] {
                    var postWithId = post
                    postWithId["postId"] = childSnapshot.key
                    posts.append(postWithId)
                }
            }

            if posts.isEmpty {
                print("No posts found for user: \(userId)")
            }

            self.userPosts = posts
            self.isLoading = false
        } withCancel: { error in
            print("Error loading posts: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }

    // Edit post (caption or image)
    private func editPost(postId: String, post: [String: Any]) {
        let caption = post["caption"] as? String ?? ""
        let currentImageUrl = post["postImageUrl"] as? String

        var newImageFile: UIImage?
        var newImageUrl: String?
        
        let captionController = TextFieldAlert(title: "Edit Caption", message: "Enter new caption", text: caption) { newCaption in
            if let newImage = newImageFile {
                uploadImage(image: newImage, postId: postId) { url in
                    newImageUrl = url
                    updatePost(postId: postId, caption: newCaption, imageUrl: newImageUrl ?? currentImageUrl)
                }
            } else {
                updatePost(postId: postId, caption: newCaption, imageUrl: currentImageUrl)
            }
        }

        UIApplication.shared.windows.first?.rootViewController?.present(captionController, animated: true)
    }

    // Upload image to Firebase Storage
    private func uploadImage(image: UIImage, postId: String, completion: @escaping (String?) -> Void) {
        let ref = Storage.storage().reference().child("posts/\(postId)/\(UUID().uuidString).png")
        guard let imageData = image.pngData() else { return completion(nil) }

        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return completion(nil)
            }
            ref.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }

    // Update post in Firebase Database
    private func updatePost(postId: String, caption: String, imageUrl: String?) {
        let ref = Database.database().reference().child("posts").child(postId)
        var updates: [String: Any] = ["caption": caption]
        if let imageUrl = imageUrl {
            updates["postImageUrl"] = imageUrl
        }

        ref.updateChildValues(updates) { error, _ in
            if let error = error {
                print("Update error: \(error.localizedDescription)")
                return
            }
            loadUserPosts() // Reload posts after update
        }
    }

    // Delete post from Firebase
    private func deletePost(postId: String) {
        let ref = Database.database().reference().child("posts").child(postId)
        ref.removeValue { error, _ in
            if let error = error {
                print("Delete error: \(error.localizedDescription)")
                return
            }
            loadUserPosts() // Reload posts after deletion
        }
    }
}

// Row to display individual posts
struct PostRow: View {
    let post: [String: Any]
    let onEdit: ([String: Any]) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        HStack {
            if let imageUrl = post["postImageUrl"] as? String, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            VStack(alignment: .leading) {
                Text(post["caption"] as? String ?? "No Caption")
                    .font(.headline)
            }
            Spacer()
            Menu {
                Button("Edit", action: { onEdit(post) })
                Button("Delete", role: .destructive, action: { onDelete(post["postId"] as! String) })
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
}

// Helper for alert text field
class TextFieldAlert: UIAlertController {
    private var actionHandler: (String) -> Void

    init(title: String, message: String?, text: String, action: @escaping (String) -> Void) {
        self.actionHandler = action
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.message = message
        addTextField { $0.text = text }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            if let text = self.textFields?.first?.text {
                action(text)
            }
        }

        addAction(cancelAction)
        addAction(saveAction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
