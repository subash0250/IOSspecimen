import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserManagementViewModel: ObservableObject {
    @Published var users: [AppUser] = []
    @Published var isLoading = false
    @Published var error: IdentifiableError?

    private let usersRef = Database.database().reference(withPath: "users")

    enum UserAction {
        case ban
        case updateRole(String)
        case remove
        case viewHistory
    }

    func fetchUsers() {
        isLoading = true
        usersRef.observeSingleEvent(of: .value) { snapshot in
            self.isLoading = false
            guard let value = snapshot.value as? [String: Any] else { return }
            self.users = value.compactMap { (key, userData) in
                guard let userDict = userData as? [String: Any] else { return nil }
                return AppUser(id: key, data: userDict)
            }
        } withCancel: { error in
            self.isLoading = false
            self.error = IdentifiableError(error: error)
        }
    }

    func handleUserAction(action: UserAction, user: AppUser) {
        switch action {
        case .ban:
            toggleBanStatus(user: user)
        case .updateRole(let newRole):
            updateUserRole(user: user, newRole: newRole)
        case .remove:
            removeUser(user: user)
        case .viewHistory:
            viewUserHistory(userId: user.id)
        }
    }

    private func toggleBanStatus(user: AppUser) {
        usersRef.child(user.id).updateChildValues(["isBanned": !user.isBanned]) { error, _ in
            if let error = error {
                self.error = IdentifiableError(error: error)
            } else {
                self.fetchUsers()
            }
        }
    }

    private func updateUserRole(user: AppUser, newRole: String) {
        usersRef.child(user.id).updateChildValues(["userRole": newRole]) { error, _ in
            if let error = error {
                self.error = IdentifiableError(error: error)
            } else {
                self.fetchUsers()
            }
        }
    }

    private func removeUser(user: AppUser) {
        usersRef.child(user.id).removeValue { error, _ in
            if let error = error {
                self.error = IdentifiableError(error: error)
            } else {
                self.deleteAuthUser(userId: user.id)
            }
        }
    }

    private func deleteAuthUser(userId: String) {
        // Check if the admin is trying to delete their own account
        guard let currentUser = Auth.auth().currentUser, currentUser.uid != userId else {
            self.error = IdentifiableError(
                error: NSError(
                    domain: "",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Admin cannot delete their own account."]
                )
            )
            return
        }

        usersRef.child(userId).removeValue { error, _ in
            if let error = error {
                self.error = IdentifiableError(error: error)
            } else {
                self.fetchUsers()
                self.showSuccessMessage("User deleted successfully")
            }
        }
    }

    
    private func showSuccessMessage(_ message: String) {
        print(message)
    }


    func viewUserHistory(userId: String) {
                print("Navigate to UserHistory for userId: \(userId)")
    }

}
