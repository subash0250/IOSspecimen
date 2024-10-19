//
//  PostTab.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//


import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseDatabase
import PhotosUI
import FirebaseAuth

struct PostScreen: View {
    @State private var caption: String = ""
    @State private var postImage: UIImage? = nil
    @State private var isImagePickerPresented = false
    @State private var isLoading = false
    @State private var successMessage: String? = nil
    @State private var locationName: String? = nil // Store city name
    @State private var latitude: Double? = nil // Store latitude
    @State private var longitude: Double? = nil // Store longitude

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let postImage = postImage {
                        Image(uiImage: postImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .onTapGesture {
                                isImagePickerPresented = true
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 200)
                            .overlay(Text("Tap to select image").foregroundColor(.white))
                            .onTapGesture {
                                isImagePickerPresented = true
                            }
                    }

                    TextField("Write a caption...", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    NavigationLink(destination: LocationSearchScreen(onSelectLocation: { name, lat, lon in
                        // Handle the selected location
                        locationName = name
                        latitude = lat
                        longitude = lon
                    })) {
                        Text("Tag Location")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    if let locationName = locationName {
                        Text("Location: \(locationName)")
                            .font(.headline)
                    }

                    if isLoading {
                        ProgressView("Uploading post...")
                    } else {
                        Button(action: uploadPost) {
                            Text("Upload Post")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $postImage)
            }
        }
    }

    // MARK: - Functions

    func selectLocation(name: String, lat: Double, lon: Double) {
        self.locationName = name
        self.latitude = lat
        self.longitude = lon
    }

    func uploadPost() {
        guard let user = Auth.auth().currentUser,
              let image = postImage,
              let imageData = image.jpegData(compressionQuality: 0.8),
              !caption.isEmpty,
              let locationName = locationName else {
            print("Missing data or image")
            return
        }

        isLoading = true
        let postId = UUID().uuidString
        let storageRef = Storage.storage().reference().child("posts/\(postId).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                isLoading = false
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    isLoading = false
                    return
                }

                guard let downloadURL = url else { return }
                let timestamp = Int(Date().timeIntervalSince1970)

                let postData: [String: Any] = [
                    "postId": postId,
                    "caption": caption,
                    "postImageUrl": downloadURL.absoluteString,
                    "timestamp": timestamp,
                    "userId": user.uid,
                    "locationName": locationName,
                    "latitude": latitude ?? 0.0,
                    "longitude": longitude ?? 0.0
                ]

                let dbRef = Database.database().reference().child("posts").child(postId)
                dbRef.setValue(postData) { error, _ in
                    isLoading = false

                    if let error = error {
                        print("Error saving post: \(error.localizedDescription)")
                    } else {
                        successMessage = "Post uploaded successfully!"
                        clearFields()
                    }
                }
            }
        }
    }

    func clearFields() {
        caption = ""
        postImage = nil
        locationName = nil
        latitude = nil
        longitude = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            successMessage = nil
        }
    }
}

//
//import SwiftUI
//import Firebase
//import FirebaseStorage
//import FirebaseAuth
//import FirebaseDatabase
//
//struct PostScreen: View {
//    @State private var caption: String = ""
//    @State private var postImage: UIImage? = nil
//    @State private var isImagePickerPresented = false
//    @State private var isLoading = false
//    @State private var successMessage: String? = nil
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Create a Post")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding()
//
//            if let postImage = postImage {
//                Image(uiImage: postImage)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(height: 200)
//                    .clipShape(RoundedRectangle(cornerRadius: 15))
//                    .onTapGesture {
//                        isImagePickerPresented = true
//                    }
//            } else {
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(Color.gray.opacity(0.5))
//                    .frame(height: 200)
//                    .overlay(Text("Tap to select image").foregroundColor(.white))
//                    .onTapGesture {
//                        isImagePickerPresented = true
//                    }
//            }
//
//            TextField("Caption", text: $caption)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            Button(action: {
//                savePost()
//            }) {
//                Text("Post")
//                    .font(.headline)
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .sheet(isPresented: $isImagePickerPresented) {
//                ImagePicker(image: $postImage)
//            }
//
//            // Loading Indicator
//            if isLoading {
//                ProgressView("Creating post...")
//                    .progressViewStyle(CircularProgressViewStyle())
//                    .padding()
//            }
//
//            // Success Message
//            if let successMessage = successMessage {
//                Text(successMessage)
//                    .font(.headline)
//                    .foregroundColor(.green)
//                    .padding()
//            }
//
//            Spacer()
//        }
//        .padding()
//    }
//
//    func savePost() {
//        guard let user = Auth.auth().currentUser,
//              let image = postImage,
//              let imageData = image.jpegData(compressionQuality: 0.8) else {
//            return
//        }
//
//        // Create a unique post ID
//        let postId = UUID().uuidString
//        let timestamp = Int(Date().timeIntervalSince1970)
//
//        let storageRef = Storage.storage().reference().child("post_images/\(postId).jpg")
//
//        // Show loading indicator
//        isLoading = true
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
//                    // Create post data
//                    let postData: [String: Any] = [
//                        "caption": caption,
//                        "postId": postId,
//                        "postImageUrl": url.absoluteString,
//                        "timestamp": timestamp,
//                        "userId": user.uid
//                    ]
//
//                    // Save post data to Realtime Database
//                    let dbRef = Database.database().reference().child("posts").child(postId)
//                    dbRef.setValue(postData) { error, _ in
//                        // Hide loading indicator
//                        isLoading = false
//
//                        if let error = error {
//                            print("Error saving post: \(error.localizedDescription)")
//                        } else {
//                            // Clear fields after posting
//                            caption = ""
//                            postImage = nil
//
//                            // Show success message
//                            successMessage = "Post created successfully!"
//                            // Remove success message after 2 seconds
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                successMessage = nil
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//

