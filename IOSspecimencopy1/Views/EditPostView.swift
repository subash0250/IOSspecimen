////
////  EditPostView.swift
////  IOSspecimencopy1
////
////  Created by Subash Gaddam on 2024-11-03.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseDatabase
//import FirebaseStorage
//
//struct EditPostView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var post: Post
//    @State private var newCaption: String = ""
//    @State private var newPostImage: UIImage?
//    @State private var showImagePicker = false
//    @State private var isLoading = false
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Edit Post")
//                .font(.largeTitle)
//                .padding()
//
//         
//            if !post.postImageUrl.isEmpty, let url = URL(string: post.postImageUrl) {
//                AsyncImage(url: url) { image in
//                    image.resizable()
//                         .scaledToFit()
//                         .frame(height: 200)
//                         .cornerRadius(10)
//                } placeholder: {
//                    ProgressView()
//                }
//            } else {
//               
//                Text("No image available")
//                    .foregroundColor(.gray)
//            }
//
//            // Button to select a new image
//            Button(action: {
//                showImagePicker = true
//            }) {
//                Text("Select New Image")
//                    .foregroundColor(.blue)
//            }
//
//            
//            TextField("Caption", text: $newCaption)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            
//            Button(action: {
//                updatePost()
//            }) {
//                Text("Update Post")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.black)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//        }
//        .onAppear {
//            newCaption = post.caption
//        }
//        .padding()
//        .sheet(isPresented: $showImagePicker) {
//            ImagePicker(image: $newPostImage)
//        }
//        .overlay {
//            if isLoading {
//                ProgressView("Updating...").progressViewStyle(CircularProgressViewStyle())
//            }
//        }
//    }
//
// 
//    private func updatePost() {
//        guard let user = Auth.auth().currentUser else {
//            print("User not logged in")
//            return
//        }
//
//        isLoading = true
//        
//        // Check if there's a new image to upload
//        if let image = newPostImage {
//            uploadImageAndSavePost(image: image, userId: user.uid)
//        } else {
//            // If no new image, just update the caption
//            savePost(caption: newCaption.isEmpty ? post.caption : newCaption)
//        }
//    }
//
//    
//    private func uploadImageAndSavePost(image: UIImage, userId: String) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
//        
//        // Use the existing post ID to update the post image
//        let storageRef = Storage.storage().reference().child("post_images/\(post.postId).jpg")
//
//        // Upload image to Firebase Storage
//        storageRef.putData(imageData, metadata: nil) { _, error in
//            if let error = error {
//                print("Error uploading image: \(error.localizedDescription)")
//                isLoading = false
//                return
//            }
//
//            // Get the download URL
//            storageRef.downloadURL { url, error in
//                if let error = error {
//                    print("Error getting download URL: \(error.localizedDescription)")
//                    isLoading = false
//                    return
//                }
//
//                if let url = url {
//                    // Update post data with new caption and image URL
//                    let updatedCaption = newCaption.isEmpty ? post.caption : newCaption
//                    savePost(caption: updatedCaption, imageUrl: url.absoluteString)
//                }
//            }
//        }
//    }
//
//    private func savePost(caption: String, imageUrl: String? = nil) {
//        var postData: [String: Any] = ["caption": caption]
//
//        if let imageUrl = imageUrl {
//            postData["postImageUrl"] = imageUrl
//        }
//
//        let dbRef = Database.database().reference().child("posts").child(post.postId)
//        dbRef.updateChildValues(postData) { error, _ in
//            isLoading = false
//
//            if let error = error {
//                print("Error updating post: \(error.localizedDescription)")
//            } else {
//                print("Post updated successfully!")
//                presentationMode.wrappedValue.dismiss()
//            }
//        }
//    }
//}
