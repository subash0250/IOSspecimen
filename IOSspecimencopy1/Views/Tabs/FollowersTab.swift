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


