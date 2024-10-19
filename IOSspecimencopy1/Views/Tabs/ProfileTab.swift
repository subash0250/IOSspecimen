import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase



struct ProfileScreen: View {
    @State private var userName: String?
    @State private var userBio: String?
    @State private var userProfileImage: String?
    @State private var userEmail: String?
    @State private var userId: String?
    @State private var postCount = 0
    @State private var followersCount = 0
    @State private var followingCount = 0
    @State private var isEditProfilePresented = false

    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 20) {
                    if let imageUrl = userProfileImage {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } placeholder: {
                            Image("profile_placeholder")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        }
                    }

                    Text(userName ?? "Loading...")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(userBio ?? "No bio available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()

                HStack {
                    NavigationLink(destination: UserPostsScreen(userId: userId ?? "")) {
                        _buildStatColumn(label: "Posts", count: "\(postCount)")
                    }
                    NavigationLink(destination: FollowersView(userId: userId ?? "")) {
                        _buildStatColumn(label: "Followers", count: "\(followersCount)")
                    }
                    NavigationLink(destination: FollowingScreen(userId: userId ?? "")) {
                        _buildStatColumn(label: "Following", count: "\(followingCount)")
                    }
                }
                .padding()
                Button(action: {
                    isEditProfilePresented = true
                             }) {
                Text("Edit Profile")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(30)
                }
                .padding()
                .sheet(isPresented: $isEditProfilePresented) {
                                 EditProfileScreen()
                             }

                Button(action: {
                    signOut()
                }) {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(30)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Profile")
            .onAppear(perform: loadUserData)
        }
    }

    private func _buildStatColumn(label: String, count: String) -> some View {
        VStack {
            Text(count)
                .font(.title2)
                .fontWeight(.bold)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }

    private func loadUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        userId = currentUser.uid

        let userRef = Database.database().reference().child("users/\(userId!)")
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let userData = snapshot.value as? [String: Any] {
                userName = userData["userName"] as? String ?? "Unknown"
                userBio = userData["userBio"] as? String ?? "No bio available"
                userProfileImage = userData["userProfileImage"] as? String ?? "assets/profile_placeholder.png"
               
            }
        }

        loadUserPostsCount()
        loadFollowersCount()
        loadFollowingCount()
    }

    private func loadUserPostsCount() {
        guard let userId = userId else { return }
        let postsRef = Database.database().reference().child("posts")
        
        postsRef.queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value) { snapshot in
            postCount = Int(snapshot.childrenCount)
        }
    }

    private func loadFollowersCount() {
        guard let userId = userId else { return }
        let followersRef = Database.database().reference().child("users/\(userId)/followersCount")
        
        followersRef.observeSingleEvent(of: .value) { snapshot in
            if let count = snapshot.value as? Int {
                followersCount = count
            } else {
                followersCount = 0
            }
        }
    }

    private func loadFollowingCount() {
        guard let userId = userId else { return }
        let followingRef = Database.database().reference().child("users/\(userId)/followingCount")
        
        followingRef.observeSingleEvent(of: .value) { snapshot in
            if let count = snapshot.value as? Int {
                followingCount = count
            } else {
                followingCount = 0
            }
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
            
        } catch {
            print("Error signing out: \(error)")
        }
    }
}

struct ProfileTab_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}

//
//struct UserPost: Identifiable {
//    let id: String
//    let caption: String
//    let imageUrl: String?
//}
//
//struct ProfileScreen: View {
//    @State private var profileImage: UIImage? = nil
//    @State private var username: String = ""
//    @State private var userBio: String = ""
//    @State private var followersCount: Int = 0
//    @State private var followingCount: Int = 0
//    @State private var posts: [UserPost] = []
//    @State private var isImagePickerPresented = false
//    @State private var isEditing = false
//    @State private var isLoading = false
//    @State private var successMessage: String? = nil
//
//    private var dbRef = Database.database().reference()
//
//    var body: some View {
//        VStack(spacing: 20) {
//            if isLoading {
//                ProgressView("Updating...")
//            } else {
//                // Profile image (tappable)
//                if let profileImage = profileImage {
//                    Image(uiImage: profileImage)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 150, height: 150)
//                        .clipShape(Circle())
//                        .overlay(Circle().stroke(Color.blue, lineWidth: 4))
//                        .shadow(radius: 10)
//                        .padding()
//                        .onTapGesture {
//                            isImagePickerPresented = true
//                        }
//                } else {
//                    Circle()
//                        .fill(Color.gray.opacity(0.5))
//                        .frame(width: 150, height: 150)
//                        .overlay(Text("Tap to Edit").foregroundColor(.white))
//                        .onTapGesture {
//                            isImagePickerPresented = true
//                        }
//                }
//
//                // Username
//                Text(username.isEmpty ? "No username" : username)
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.top, 10)
//
//                // Bio
//                Text(userBio.isEmpty ? "No bio available" : userBio)
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//
//                // Followers and Following Count
//                HStack {
//                    NavigationLink(destination: FollowersView(userId: Auth.auth().currentUser?.uid ?? "")) {
//                        VStack {
//                            Text("\(followersCount)")
//                                .font(.headline)
//                            Text("Followers")
//                                .font(.subheadline)
//                        }
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                    }
//
//                    NavigationLink(destination: FollowingScreen(userId: Auth.auth().currentUser?.uid ?? "")) {
//                        VStack {
//                            Text("\(followingCount)")
//                                .font(.headline)
//                            Text("Following")
//                                .font(.subheadline)
//                        }.onTapGesture(perform: {
//                           
//                            
//                        })
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(10)
//                    }
//                }
//
//
//                // Edit Profile Button
//                Button(action: {
//                    isEditing.toggle()
//                }) {
//                    Text("Edit Profile")
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//                .sheet(isPresented: $isImagePickerPresented) {
//                    ImagePicker(image: $profileImage)
//                }
//                .sheet(isPresented: $isEditing) {
//                    EditProfileView(username: $username, userBio: $userBio, profileImage: $profileImage, saveAction: saveProfileData, onSuccess: { message in
//                        successMessage = message
//                        // Remove success message after 3 seconds
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            successMessage = nil
//                        }
//                    })
//                }
//
//                // Success message
//                if let successMessage = successMessage {
//                    Text(successMessage)
//                        .foregroundColor(.green)
//                        .fontWeight(.bold)
//                }
//
//                // Posts List
//                List(posts) { post in
//                    VStack(alignment: .leading) {
//                        if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
//                            AsyncImage(url: url) { image in
//                                image
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(height: 200)
//                                    .cornerRadius(10)
//                            } placeholder: {
//                                ProgressView()
//                            }
//                        }
//                        Text(post.caption)
//                            .font(.body)
//                            .padding(.top, 5)
//                    }
//                }
//                .listStyle(PlainListStyle())
//
//                // Log Out Button
//                Button(action: logOut) {
//                    Text("Log Out")
//                        .font(.headline)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                }
//
//                Spacer()
//            }
//        }
//        .padding()
//        .onAppear {
//            fetchUserProfile()
//        }
//    }
//
//    // Fetch user profile details from Firebase
//    func fetchUserProfile() {
//        guard let user = Auth.auth().currentUser else { return }
//
//        // Fetch the username and profile image from Firebase Authentication
//        username = user.displayName ?? "Your Awesome Name"
//
//        if let photoURL = user.photoURL {
//            URLSession.shared.dataTask(with: photoURL) { data, _, _ in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        profileImage = image
//                    }
//                }
//            }.resume()
//        }
//
//      
//        dbRef.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
//            if let value = snapshot.value as? [String: Any] {
//                userBio = value["userBio"] as? String ?? ""
//                followersCount = (value["followers"] as? [String: Bool])?.count ?? 0
//                followingCount = (value["following"] as? [String: Bool])?.count ?? 0
//
//                // Fetch posts
//                if let userPosts = value["posts"] as? [String: Any] {
//                    posts = userPosts.compactMap { key, value in
//                        if let postDict = value as? [String: Any],
//                           let caption = postDict["caption"] as? String,
//                           let imageUrl = postDict["imageUrl"] as? String {
//                            return UserPost(id: key, caption: caption, imageUrl: imageUrl)
//                        }
//                        return nil
//                    }
//                }
//            }
//        }
//    }
//
//  
//    func logOut() {
//        do {
//            try Auth.auth().signOut()
//            // Redirect to sign-in page if necessary
//        } catch {
//            print("Error logging out: \(error.localizedDescription)")
//        }
//    }
//
//    
//    func saveProfileData() {
//        guard let user = Auth.auth().currentUser else { return }
//        isLoading = true // Start loading
//
//     
//        let changeRequest = user.createProfileChangeRequest()
//        changeRequest.displayName = username
//        changeRequest.commitChanges { error in
//            if let error = error {
//                print("Error updating username: \(error.localizedDescription)")
//                self.isLoading = false // Stop loading
//                return
//            }
//        }
//
//     
//        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.8) {
//            let storageRef = Storage.storage().reference().child("profile_images/\(user.uid).jpg")
//            
//            // Upload the image to Firebase Storage
//            storageRef.putData(imageData, metadata: nil) { _, error in
//                if let error = error {
//                    print("Error uploading image: \(error.localizedDescription)")
//                    self.isLoading = false // Stop loading
//                    return
//                } else {
//                    // Get the download URL
//                    storageRef.downloadURL { url, error in
//                        if let error = error {
//                            print("Error getting download URL: \(error.localizedDescription)")
//                            self.isLoading = false // Stop loading
//                            return
//                        } else if let url = url {
//                            // Update user's photo URL in Firebase Authentication
//                            let changeRequest = user.createProfileChangeRequest()
//                            changeRequest.photoURL = url
//                            changeRequest.commitChanges { error in
//                                if let error = error {
//                                    print("Error updating profile image: \(error.localizedDescription)")
//                                    self.isLoading = false // Stop loading
//                                    return
//                                } else {
//                                    // Save the profile image URL to Realtime Database
//                                    let userInfo = ["userName": username, "userBio": userBio, "userProfileImage": url.absoluteString]
//                                    dbRef.child("users").child(user.uid).updateChildValues(userInfo) { error, _ in
//                                        if let error = error {
//                                            print("Error saving user profile image URL: \(error.localizedDescription)")
//                                            self.isLoading = false // Stop loading
//                                            return
//                                        } else {
//                                            // Fetch the updated profile data (optional)
//                                            fetchUserProfile()
//                                            self.isLoading = false // Stop loading
//                                            // Success message
//                                            successMessage = "Profile updated successfully!"
//                                            // Remove success message after 3 seconds
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                                successMessage = nil
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            // Save user bio without changing the image
//            let userInfo = ["userName": username, "userBio": userBio]
//            dbRef.child("users").child(user.uid).updateChildValues(userInfo) { error, _ in
//                if let error = error {
//                    print("Error saving user bio: \(error.localizedDescription)")
//                } else {
//                    fetchUserProfile()
//                    successMessage = "Profile updated successfully!"
//                }
//                isLoading = false // Stop loading
//            }
//        }
//    }
//}
//
//      
