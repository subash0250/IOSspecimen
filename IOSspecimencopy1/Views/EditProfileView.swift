//
//  EditProfileView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct EditProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userName: String = ""
    @State private var Bio: String = ""
    @State private var profileImage: Image? = nil
    @State private var userProfileImageUrl: String? = nil
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var isLoading = false

    private var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        NavigationView {
            VStack {
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    profileImage?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 4))
                        .padding()
                    Text("Tap to change profile picture")
                }
                .sheet(isPresented: $isImagePickerPresented) {
                    ImagePicker(image: $selectedImage)
                        .onDisappear(perform: loadImage)
                }

                TextField("Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Bio", text: $Bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: saveProfile) {
                    
                    Text("Save Profile")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .onAppear(perform: loadUserProfile)
            .overlay(isLoading ? ProgressView() : nil)
        }
    }

    private func loadUserProfile() {
        let userRef = Database.database().reference().child("users/\(userId)")
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard let userData = snapshot.value as? [String: Any] else { return }
            userName = userData["userName"] as? String ?? ""
            Bio = userData["userBio"] as? String ?? ""
            if let imageUrl = userData["userProfileImage"] as? String {
                userProfileImageUrl = imageUrl
                loadImageFromURL(imageUrl)
            }
        }
    }

    private func loadImageFromURL(_ url: String) {
        guard let imageUrl = URL(string: url) else { return }
        URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    private func loadImage() {
        if let selectedImage = selectedImage {
            profileImage = Image(uiImage: selectedImage)
        }
    }

    private func saveProfile() {
        guard !userName.isEmpty else { return }
        isLoading = true
        let userRef = Database.database().reference().child("users/\(userId)")
        
        userRef.updateChildValues(["userName": userName, "userBio": Bio]) { error, _ in
            if let error = error {
                print("Error updating profile: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            if let selectedImage = selectedImage {
                uploadProfileImage(selectedImage) { imageUrl in
                    userRef.updateChildValues(["userProfileImage": imageUrl])
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                isLoading = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(userId)/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                if let downloadURL = url?.absoluteString {
                    completion(downloadURL)
                }
            }
        }
    }
}


//
//import SwiftUI
//
//struct EditProfileView: View {
//    @Binding var username: String
//    @Binding var userBio: String
//    @Binding var profileImage: UIImage?
//    var saveAction: () -> Void
//    var onSuccess: (String) -> Void
//    
//    @State private var isImagePickerPresented = false
//    @State private var isLoading = false
//    @State private var successMessage: String? = nil
//
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                // Profile Image Section
//                VStack {
//                    if let profileImage = profileImage {
//                        Image(uiImage: profileImage)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 150)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
//                            .shadow(radius: 10)
//                            .onTapGesture {
//                                isImagePickerPresented = true
//                            }
//                    } else {
//                        Button(action: {
//                            isImagePickerPresented = true
//                        }) {
//                            VStack {
//                                Image(systemName: "person.crop.circle.fill.badge.plus")
//                                    .font(.system(size: 50))
//                                    .foregroundColor(.blue)
//                                Text("Select Profile Image")
//                                    .font(.headline)
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                }
//                .padding(.top)
//
//                // Edit Info Section
//                Form {
//                    Section(header: Text("Edit Info").font(.headline)) {
//                        TextField("Username", text: $username)
//                        TextField("Bio", text: $userBio)
//                    }
//                }
//
//                // Save Button
//                Button(action: {
//                    isLoading = true
//                    saveAction()
//                    onSuccess("Profile updated successfully!")
//                    isLoading = false
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        successMessage = nil
//                    }
//                }) {
//                    Text(isLoading ? "Saving..." : "Save")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(isLoading ? Color.gray : Color.blue)
//                        .cornerRadius(10)
//                }
//                .disabled(isLoading)
//
//                // Success Message
//                if let successMessage = successMessage {
//                    Text(successMessage)
//                        .font(.subheadline)
//                        .foregroundColor(.green)
//                        .padding()
//                }
//            }
//            .navigationTitle("Edit Profile")
//            .padding()
//            .sheet(isPresented: $isImagePickerPresented) {
//                ImagePicker(image: $profileImage)
//            }
//        }
//    }
//}
//


