import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct FollowersScreen: View {
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var currentUserId: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                } else {
                    List(users) { user in
                        if user.id != currentUserId {
                            UserRow(user: user)
                        }
                    }
                }
            }
            .navigationTitle("All Users")
            .onAppear(perform: loadUsers)
        }
    }
    
    private func loadUsers() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        currentUserId = userId
        
        let ref = Database.database().reference()
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            if let usersDict = snapshot.value as? [String: Any] {
                users = usersDict.compactMap { key, value in
                    if let userInfo = value as? [String: Any],
                       let userName = userInfo["userName"] as? String {
                        return User(id: key, name: userName)
                    }
                    return nil
                }
            }
            isLoading = false
        }
    }
}

struct UserRow: View {
    let user: User
    @State private var isFollowing = false
    
    var body: some View {
        HStack {
            Text(user.name)
            Spacer()
            Button(action: {
                isFollowing ? unfollowUser() : followUser()
            }) {
                Text(isFollowing ? "Unfollow" : "Follow")
                    .padding()
                    .background(isFollowing ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .onAppear(perform: checkIfFollowing)
    }
    
    private func followUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()

        // Update following list for current user
        ref.child("users/\(currentUserId)/following/\(user.id)").setValue(true)
        
        // Update followers list for the target user
        ref.child("users/\(user.id)/followers/\(currentUserId)").setValue(true)

        // Increment the following count of the current user
        ref.child("users/\(currentUserId)/followingCount").runTransactionBlock { currentData in
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = currentCount + 1  // Update the value to MutableData
            return TransactionResult.success(withValue: currentData)
        }
        
        // Increment the followers count of the target user
        ref.child("users/\(user.id)/followersCount").runTransactionBlock { currentData in
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = currentCount + 1  // Update the value to MutableData
            return TransactionResult.success(withValue: currentData)
        }

        isFollowing = true
    }
    private func unfollowUser() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference()

        // Remove from following list of current user
        ref.child("users/\(currentUserId)/following/\(user.id)").removeValue()
        
        // Remove from followers list of the target user
        ref.child("users/\(user.id)/followers/\(currentUserId)").removeValue()

        // Decrement the following count of the current user
        ref.child("users/\(currentUserId)/followingCount").runTransactionBlock { currentData in
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = max(0, currentCount - 1)  // Ensure it doesn't go negative
            return TransactionResult.success(withValue: currentData)
        }

        // Decrement the followers count of the target user
        ref.child("users/\(user.id)/followersCount").runTransactionBlock { currentData in
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = max(0, currentCount - 1)  // Ensure it doesn't go negative
            return TransactionResult.success(withValue: currentData)
        }

        isFollowing = false
    }
    private func checkIfFollowing() {
          guard let currentUserId = Auth.auth().currentUser?.uid else { return }
          let ref = Database.database().reference()
          
          ref.child("users/\(currentUserId)/following/\(user.id)").observeSingleEvent(of: .value) { snapshot in
              isFollowing = snapshot.exists()
          }
      }
  }


struct User: Identifiable {
    let id: String
    let name: String
}

struct FollowersTab_Previews: PreviewProvider {
    static var previews: some View {
        FollowersScreen()
    }
}



//import SwiftUI
//import Firebase
//import FirebaseAuth
////
////struct User: Identifiable {
////    let id: String
////    let name: String
////    let profilePicUrl: String
////    var isFollowing: Bool
////}
////
////struct FollowersScreen: View {
////    @State private var users: [User] = []
////    @State private var currentUserId: String = "currentUserId"  
////
////    var body: some View {
////        List(users) { user in
////            HStack {
////                AsyncImage(url: URL(string: user.profilePicUrl)) { image in
////                    image.resizable()
////                        .aspectRatio(contentMode: .fit)
////                        .frame(width: 50, height: 50)
////                        .clipShape(Circle())
////                } placeholder: {
////                    ProgressView()
////                }
////
////                Text(user.name)
////
////                Spacer()
////
////                Button(action: {
////                    toggleFollow(user: user)
////                }) {
////                    Text(user.isFollowing ? "Unfollow" : "Follow")
////                        .foregroundColor(.white)
////                        .padding()
////                        .background(user.isFollowing ? Color.red : Color.blue)
////                        .cornerRadius(8)
////                }
////            }
////        }
////        .onAppear(perform: fetchUsers)
////    }
////
////    func fetchUsers() {
////        let ref = Database.database().reference().child("users")
////        ref.observe(.value) { snapshot in
////            var fetchedUsers: [User] = []
////
////            // Iterate through each child in the snapshot
////            for child in snapshot.children {
////                if let snapshot = child as? DataSnapshot,
////                   let dict = snapshot.value as? [String: Any] {
////                    // Safely parse each user's data
////                    let userId = snapshot.key
////                    let name = dict["userName"] as? String ?? "Unknown"
////                    let profilePicUrl = dict["userProfileImage"] as? String ?? ""
////                    
////                    // Fetch follow status for each user
////                    fetchFollowStatus(for: userId) { isFollowing in
////                        let user = User(
////                            id: userId,
////                            name: name,
////                            profilePicUrl: profilePicUrl,
////                            isFollowing: isFollowing
////                        )
////                        fetchedUsers.append(user)
////                    }
////                } else {
////                    // Print detailed error to help debug
////                    print("Failed to parse user data for child: \(child)")
////                }
////            }
////            
////            // Update the users array after all the parsing
////            DispatchQueue.main.async {
////                self.users = fetchedUsers
////            }
////        }
////    }
////
////    func fetchFollowStatus(for userId: String, completion: @escaping (Bool) -> Void) {
////        let ref = Database.database().reference().child("users").child(currentUserId).child("followers").child(userId)
////        ref.observeSingleEvent(of: .value) { snapshot in
////            let isFollowing = snapshot.exists()
////            completion(isFollowing)
////        }
////    }
////    
////    func toggleFollow(user: User) {
////        let followRef = Database.database().reference().child("users").child(currentUserId).child("followers").child(user.id)
////        let followerRef = Database.database().reference().child("users").child(user.id).child("followers").child(currentUserId)
////        
////        if user.isFollowing {
////            // Unfollow logic
////            followRef.removeValue()
////            followerRef.removeValue()
////            // Decrease follower count
////            updateFollowerCount(for: user.id, increment: false)
////        } else {
////            // Follow logic
////            followRef.setValue(true)
////            followerRef.setValue(true)
////            // Increase follower count
////            updateFollowerCount(for: user.id, increment: true)
////        }
////        
////        // Update UI
////        if let index = users.firstIndex(where: { $0.id == user.id }) {
////            users[index].isFollowing.toggle()
////        }
////    }
////    
////    func updateFollowerCount(for userId: String, increment: Bool) {
////        let userRef = Database.database().reference().child("users").child(userId)
////        userRef.child("followersCount").observeSingleEvent(of: .value) { snapshot in
////            if let count = snapshot.value as? Int {
////                let newCount = increment ? count + 1 : count - 1
////                userRef.child("followersCount").setValue(newCount)
////            }
////        }
////    }
////}
////
////#Preview {
////    FollowersScreen()
////}
//import SwiftUI
//import Firebase
//import FirebaseDatabase
//
//struct User: Identifiable {
//    let id: String
//    let name: String
//    let profilePicUrl: String
//    var isFollowing: Bool
//}
//
//struct FollowersScreen: View {
//    @State private var users: [User] = []
//    @State private var currentUserId: String = Auth.auth().currentUser?.uid ?? ""
//    
//    var body: some View {
//        NavigationView {
//            List(users) { user in
//                HStack {
//                    // Profile picture with AsyncImage
//                    AsyncImage(url: URL(string: user.profilePicUrl)) { image in
//                        image.resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                    } placeholder: {
//                        ProgressView()
//                    }
//
//                    // Display user name
//                    Text(user.name)
//                        .font(.headline)
//                        .padding(.leading, 8)
//
//                    Spacer()
//
//                    // Follow/Unfollow button
//                    Button(action: {
//                        toggleFollow(user: user)
//                    }) {
//                        Text(user.isFollowing ? "Unfollow" : "Follow")
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(user.isFollowing ? Color.red : Color.blue)
//                            .cornerRadius(8)
//                    }
//                }
//            }
//            .onAppear(perform: fetchUsers)
//            .navigationTitle("Followers")
//        }
//    }
//
//    // Fetch all users from the Realtime Database
//    func fetchUsers() {
//        let ref = Database.database().reference().child("users")
//        ref.observeSingleEvent(of: .value) { snapshot in
//            var fetchedUsers: [User] = []
//            
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot,
//                   let dict = snapshot.value as? [String: Any],
//                   let name = dict["userName"] as? String,
//                   let profilePicUrl = dict["userProfileImage"] as? String {
//                    
//                    let userId = snapshot.key
//                    
//                    // Skip adding the current user to the list
//                    if userId != currentUserId {
//                        fetchFollowStatus(for: userId) { isFollowing in
//                            let user = User(id: userId, name: name, profilePicUrl: profilePicUrl, isFollowing: isFollowing)
//                            fetchedUsers.append(user)
//                            
//                            // Ensure UI is updated only after all users are processed
//                            DispatchQueue.main.async {
//                                self.users = fetchedUsers
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // Check if the current user is following the target user
//    func fetchFollowStatus(for userId: String, completion: @escaping (Bool) -> Void) {
//        let followRef = Database.database().reference()
//            .child("users/\(currentUserId)/following/\(userId)")
//        
//        followRef.observeSingleEvent(of: .value) { snapshot in
//            completion(snapshot.exists())
//        }
//    }
//
//    // Toggle follow/unfollow functionality
//    func toggleFollow(user: User) {
//        let followRef = Database.database().reference().child("users")
//        let currentUserFollowingRef = followRef.child("\(currentUserId)/following/\(user.id)")
//        let targetUserFollowersRef = followRef.child("\(user.id)/followers/\(currentUserId)")
//        
//        if user.isFollowing {
//            // Unfollow logic: Remove from following and followers
//            currentUserFollowingRef.removeValue()
//            targetUserFollowersRef.removeValue()
//            updateFollowerCount(for: user.id, increment: false)
//        } else {
//            // Follow logic: Add to following and followers
//            currentUserFollowingRef.setValue(true)
//            targetUserFollowersRef.setValue(true)
//            updateFollowerCount(for: user.id, increment: true)
//        }
//        
//        // Update local UI state
//        if let index = users.firstIndex(where: { $0.id == user.id }) {
//            users[index].isFollowing.toggle()
//        }
//    }
//
//    // Update the follower count when following/unfollowing
//    func updateFollowerCount(for userId: String, increment: Bool) {
//        let userRef = Database.database().reference().child("users").child(userId).child("followersCount")
//        
//        userRef.observeSingleEvent(of: .value) { snapshot in
//            if let count = snapshot.value as? Int {
//                let newCount = increment ? count + 1 : count - 1
//                userRef.setValue(newCount)
//            }
//        }
//    }
//}
//
//#Preview {
//    FollowersScreen()
//}
