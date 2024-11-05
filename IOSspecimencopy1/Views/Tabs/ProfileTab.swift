import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase



struct ProfileScreen: View {
    @State private var userName: String?
    @State private var userBio: String?
    @State private var userProfileImage: String?
    @State private var userId: String?
    @State private var postCount = 0
    @State private var followersCount = 0
    @State private var followingCount = 0
    @State private var isEditProfilePresented = false
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.presentationMode) var presentationMode
    @State private var successMessage: String? = nil
    @State private var warningMessage: String? = nil
    @State private var userWarnings: [UserWarning] = []
    @State private var userRole: String = ""
    private var dbRef = Database.database().reference()


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

                    Text(userName ?? "No UserName")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(userBio ?? "No bio available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                if let warningMessage = warningMessage {
                    Text(warningMessage)
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }

                // Display user warnings
                ForEach(userWarnings, id: \.id) { warning in
                    VStack(alignment: .leading) {
                        Text(warning.message)
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        Text("Post Caption: \(warning.postId)")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium // Customize this as needed
                            formatter.timeStyle = .short // Customize this as needed
                            return formatter
                        }()
                        let date = Date(timeIntervalSince1970: warning.timestamp / 1000.0)
                        Text("Time: \(dateFormatter.string(from: date))")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        Divider()
                    }
                    .padding(.vertical, 5)
                }

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
                .foregroundColor(.blue)
                
                Button(action: {
                    isEditProfilePresented = true
                             }) {
                Text("Edit Profile")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300 )
                        .background(Color.black)
                        .cornerRadius(30)
                }
                .padding()
                .sheet(isPresented: $isEditProfilePresented) {
                                 EditProfileScreen()
                             }
                
                if userRole == "moderator" {
                    NavigationLink(destination: ModeratorUsersView()) {
                        Text("All Posts")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300 )
                            .background(Color.black)
                            .cornerRadius(30)
                    }
                } else if userRole == "admin" {
                    NavigationLink(destination: AdminHomeScreen()) {
                        Text("All Users")
                            .padding()
                            .frame(width: 300 )
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                }

            // Success message
            if let successMessage = successMessage {
                Text(successMessage)
                .foregroundColor(.black)
                .fontWeight(.bold)
                 }
                Button(action: logOut) {
                    Text("Log Out")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 300 )
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
//        guard let currentUser = Auth.auth().currentUser else { return }
//        userId = currentUser.uid
//
//        let userRef = Database.database().reference().child("users/\(userId!)")
//        userRef.observeSingleEvent(of: .value) { snapshot in
//            if let userData = snapshot.value as? [String: Any] {
//                userName = userData["userName"] as? String ?? "Unknown"
//                userBio = userData["userBio"] as? String ?? "No bio available"
//                userProfileImage = userData["userProfileImage"] as? String ?? "assets/profile_placeholder.png"
//               
//            }
//        }
        guard let user = Auth.auth().currentUser else { return }

                // Fetch the user details (username and profile image) from the "users" node in Firebase Realtime Database
        dbRef.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot  in
                    if let value = snapshot.value as? [String: Any] {
                        // Fetch the username
                        if let fetchedUsername = value["userName"] as? String {
                            DispatchQueue.main.async {
                                self.userName = fetchedUsername
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.userName = "Your Awesome Name" // Fallback if no username is found
                            }
                        }
                        self.userRole = value["userRole"] as? String ?? ""
                        // Set the user role

                                        // Set warning message based on user role
                                        switch self.userRole {
                                        case "moderator":
                                            self.warningMessage = "You are a Moderator!."
                                        case "admin":
                                            self.warningMessage = "You are an Admin!."
                                        default:
                                            self.warningMessage = nil
                                        }
                      
                        if let profileImageUrlString = value["userProfileImage"] as? String,
                           let profileImageUrl = URL(string: profileImageUrlString) {
                           
                            URLSession.shared.dataTask(with: profileImageUrl) { data, _, _ in
                                if let data = data, let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        self.userProfileImage = value["userProfileImage"] as? String ?? "assets/profile_placeholder.png"
                                    }
                                }
                            }.resume()
                        }
                        if let fetchedBio = value["userBio"] as? String {
                            DispatchQueue.main.async {
                                self.userBio = fetchedBio
                            }
                        }
                        // Fetch user warnings for regular users
                                       if self.userRole == "user" {
                                           self.fetchUserWarnings(userId: user.uid)
                                       }
                    } else {
                        DispatchQueue.main.async {
                            // Handle case where user data is not found
                            self.userName = "Your Awesome Name"
                            self.userBio = "No bio available"
                        }
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

    private func logOut() {
            firebaseService.signOut()
            presentationMode.wrappedValue.dismiss()
        }
    // Model for user warning
      struct UserWarning: Identifiable {
          let id: String
          let message: String
          let postId: String
          let timestamp: Double
      }

      
      func fetchUserWarnings(userId: String) {
          dbRef.child("users").child(userId).child("userWarnings").observeSingleEvent(of: .value) { snapshot in
              // Check if snapshot contains data
              if let warningsData = snapshot.value as? [String: Any] {
                  var warnings: [UserWarning] = []

                  let dispatchGroup = DispatchGroup() // Create a DispatchGroup to manage async tasks

                  for (key, value) in warningsData {
                      if let warningDict = value as? [String: Any],
                         let message = warningDict["message"] as? String,
                         let postId = warningDict["postId"] as? String,
                         let timestamp = warningDict["timestamp"] as? Double {

                          dispatchGroup.enter() // Enter the group for each postId fetch

                          // Fetch the post caption using the postId
                          self.dbRef.child("posts").child(postId).observeSingleEvent(of: .value) { postSnapshot in
                              if let postData = postSnapshot.value as? [String: Any],
                                 let caption = postData["caption"] as? String {
                                  // Create the UserWarning with the caption included
                                  let userWarning = UserWarning(id: key, message: "\(message)", postId: caption, timestamp: timestamp)
                                  warnings.append(userWarning)
                              } else {
                                  // If post data is not found, create a warning without the caption
                                  let userWarning = UserWarning(id: key, message: message, postId: postId, timestamp: timestamp)
                                  warnings.append(userWarning)
                              }

                              dispatchGroup.leave() // Leave the group after the fetch
                          }
                      }
                  }

                  // Notify when all async fetches are complete
                  dispatchGroup.notify(queue: .main) {
                      self.userWarnings = warnings
                  }
              } else {
                  DispatchQueue.main.async {
                      self.userWarnings = [] // Clear warnings if no data is found
                  }
              }
          } withCancel: { error in
              // Handle potential error
              print("Error fetching user warnings: \(error.localizedDescription)")
              DispatchQueue.main.async {
                  self.userWarnings = [] // Clear warnings if there's an error
              }
          }
      }



}

struct ProfileTab_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
