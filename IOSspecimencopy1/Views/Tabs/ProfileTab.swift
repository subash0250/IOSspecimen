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
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode


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

//                Button(action: {
//                    firebaseService.signOut()
//                }) {
//                    Text("Log Out")
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.black)
//                        .cornerRadius(30)
//                }
//                .padding()
                Button(action: logOut) {
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

//    private func signOut() {
//        do {
//            try Auth.auth().signOut()
//            presentationMode.wrappedValue.dismiss()
//           
//          
//        } catch {
//            print("Error signing out: \(error)")
//        }
//    }
    private func logOut() {
            firebaseService.signOut()
            presentationMode.wrappedValue.dismiss()
        }

}

struct ProfileTab_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
