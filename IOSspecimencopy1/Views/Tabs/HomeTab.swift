//
//  HomeTab.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct HomeScreen: View {
    @State private var posts: [Post] = []
        @State private var dbRef = Database.database().reference()
        @State private var userId = Auth.auth().currentUser?.uid ?? ""
        @State private var selectedImage: UIImage? = nil
        @State private var isImagePickerPresented = false
        @State private var selectedPost: Post? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(posts) { post in
                        VStack(alignment: .leading, spacing: 10) {
                            if let userData = post.userData {
                                HStack {
                                    Image(uiImage: userData.profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                        .padding(5)
                                    
                                    Text(userData.userName)
                                        .font(.headline)
                                    
                                    Spacer()
                                    if post.userId == userId {
                                            Button(action: { showEditDialog(for: post) }) {
                                                Image(systemName: "pencil")
                                                        .foregroundColor(.blue)
                                                                }

                                        Button(action: { deletePost(post) }) {
                                                Image(systemName: "trash")
                                            .foregroundColor(.red)
                                                        }
                                                    }
                                    else {
                                                                            // Flag button only for non-creators
                                                                            Button(action: { flagPost(post) }) {
                                                                                Image(systemName: "flag")
                                                                                    .foregroundColor(.orange)
                                                                            }
                                                                        }
                                                                   
                                }
                                .padding(.horizontal, 10)
                                .padding(.top, 5)
                            }

                            // Post Image
                            AsyncImage(url: URL(string: post.postImageUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)

                            
                            HStack(spacing: 20) {
                                
                                Button(action: {
                                     Task {
                                         await handleLike(for: post)
                                     }
                                 }) {
                                     HStack {
                                         Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                             .resizable()
                                             .frame(width: 24, height: 24)
                                             .foregroundColor(post.isLiked ? .red : .black)

                                         Text("\(post.likes.count)")
                                             .font(.subheadline)
                                     }
                                 }
                                NavigationLink(destination: CommentScreen(postId: post.postId)) {
                                    Image(systemName: "message")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }

                                Button(action: {
                                    sharePost(imageUrl: post.postImageUrl, caption: post.caption)
                                }) {
                                    Image(systemName: "paperplane")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                            }
                            .padding(.horizontal, 10)

                            // Post Caption
                            Text(post.caption)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 10)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
        }
        .onAppear {
            fetchPosts()
        }.sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $selectedImage)
                .onDisappear {
                    if let image = selectedImage, let post = selectedPost {
                        uploadImage(image, for: post)
                    }
                }
        }
    }


    func flagPost(_ post: Post) {
           let flaggedData: [String: Any] = [
               "flaggedPostID": post.postId,
               "flaggedBy": userId,
               "reason": "Inappropriate content", 
               "timestamp": Int(Date().timeIntervalSince1970)
           ]

           dbRef.child("flaggedPosts").childByAutoId().setValue(flaggedData) { error, _ in
               if let error = error {
                   print("Error flagging post: \(error.localizedDescription)")
               } else {
                   print("Post flagged successfully.")
               }
           }
       }
    
    func handleLike(for post: Post) async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let index = posts.firstIndex(where: { $0.postId == post.postId }) else { return }
        
        // Toggle state optimistically
        var updatedPost = posts[index]
        updatedPost.isLiked.toggle()

        if updatedPost.isLiked {
            updatedPost.likes.append(userId)
        } else {
            updatedPost.likes.removeAll { $0 == userId }
        }

        // Update the UI immediately
        DispatchQueue.main.async {
            self.posts[index] = updatedPost
        }

        let postRef = dbRef.child("posts").child(post.postId)

        do {
            let snapshot = try await postRef.getData()
            guard let postDict = snapshot.value as? [String: Any] else { return }

            var likes = postDict["likes"] as? [String: Bool] ?? [:]
            var currentLikeCount = postDict["likeCount"] as? Int ?? 0

            // Sync with Firebase
            if updatedPost.isLiked {
                likes[userId] = true
                currentLikeCount += 1
            } else {
                likes.removeValue(forKey: userId)
                currentLikeCount = max(0, currentLikeCount - 1)
            }

            try await postRef.updateChildValues([
                "likes": likes,
                "likeCount": currentLikeCount
            ])

        } catch {
            print("Error updating like: \(error.localizedDescription)")
        }
    }


    // Fetch posts with user data and likes
    func fetchPosts() {
           guard let currentUserId = Auth.auth().currentUser?.uid else { return }
           
           dbRef.child("posts").observe(.value) { snapshot in
               var newPosts: [Post] = []

               for child in snapshot.children {
                   if let snapshot = child as? DataSnapshot,
                      let dict = snapshot.value as? [String: Any],
                      let postId = dict["postId"] as? String,
                      let userId = dict["userId"] as? String,
                      let postImageUrl = dict["postImageUrl"] as? String,
                      let caption = dict["caption"] as? String {

                       let likes = (dict["likes"] as? [String: Bool])?.keys.map { $0 } ?? []
                       let isLiked = likes.contains(currentUserId)

                       let post = Post(postId: postId, userId: userId, postImageUrl: postImageUrl, caption: caption, likes: likes, isLiked: isLiked)
                       newPosts.append(post)
                   }
               }

               self.posts = newPosts
               fetchUserDetails(for: newPosts)
           }
       }

    // Fetch user details for each post
    func fetchUserDetails(for posts: [Post]) {
           for (index, post) in posts.enumerated() {
               dbRef.child("users").child(post.userId).observeSingleEvent(of: .value) { snapshot in
                   if let userDict = snapshot.value as? [String: Any],
                      let userName = userDict["userName"] as? String,
                      let userProfileImage = userDict["userProfileImage"] as? String,
                      let imageUrl = URL(string: userProfileImage) {
                       
                       URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                           if let data = data, let image = UIImage(data: data) {
                               DispatchQueue.main.async {
                                   self.posts[index].userData = UserData(userName: userName, profileImage: image)
                               }
                           }
                       }.resume()
                   }
               }
           }
       }

    func sharePost(imageUrl: String, caption: String) {
          let textToShare = "\(caption)\n\(imageUrl)"
          let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
          UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
      }

    
    func deletePost(_ post: Post) {
            dbRef.child("posts").child(post.postId).removeValue { error, _ in
                if let error = error {
                    print("Error deleting post: \(error.localizedDescription)")
                } else {
                    posts.removeAll { $0.postId == post.postId }
                }
            }
        }
    
    func showEditDialog(for post: Post) {
            let alert = UIAlertController(title: "Edit Post", message: "Update your caption", preferredStyle: .alert)

            alert.addTextField { textField in
                textField.text = post.caption
            }

            let imagePickerAction = UIAlertAction(title: "Change Image", style: .default) { _ in
                selectedPost = post
                isImagePickerPresented = true
            }
            alert.addAction(imagePickerAction)

            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let updatedCaption = alert.textFields?.first?.text else { return }
                savePostChanges(post: post, newCaption: updatedCaption)
            }

            alert.addAction(saveAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               let rootViewController = keyWindow.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    func uploadImage(_ image: UIImage, for post: Post) {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
            let storageRef = Storage.storage().reference().child("postImages/\(post.postId).jpg")

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    print("Failed to upload image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, _ in
                    guard let imageUrl = url?.absoluteString else { return }
                    dbRef.child("posts").child(post.postId).updateChildValues(["postImageUrl": imageUrl])
                }
            }
        }
    
    func savePostChanges(post: Post, newCaption: String) {
           dbRef.child("posts").child(post.postId).updateChildValues(["caption": newCaption]) { error, _ in
               if let error = error {
                   print("Error updating post: \(error.localizedDescription)")
               } else if let index = posts.firstIndex(where: { $0.postId == post.postId }) {
                   posts[index].caption = newCaption
               }
           }
       }

}



struct Post: Identifiable {
    let id = UUID()
    let postId: String
    let userId: String
    let postImageUrl: String
    var caption: String
    var likes: [String] = []
    var isLiked: Bool = false
    var userData: UserData?
}


struct UserData {
    let userName: String
    let profileImage: UIImage
}
