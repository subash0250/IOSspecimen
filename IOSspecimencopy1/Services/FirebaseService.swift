//
//  FirebaseService.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class FirebaseService: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var destination: Destination? = nil
    private let auth = Auth.auth()
    private var dbRef = Database.database().reference()

    
    enum Destination: Identifiable {
            case admin, moderator, user, signIn

            var id: String {
                switch self {
                case .admin: return "admin"
                case .moderator: return "moderator"
                case .user: return "user"
                case .signIn: return "signIn"
                }
            }
        }
    
    init() {
        
        checkAuthStatus()
        
        _ = auth.addStateDidChangeListener { auth, user in
            if let _ = user {
                self.isLoggedIn = true
            } else {
                self.isLoggedIn = false
            }
        }
    }
    
    func checkAuthStatus() {
            if let user = auth.currentUser {
                fetchUserRole(userID: user.uid)
            } else {
                DispatchQueue.main.async {
                    self.destination = .signIn
                }
            }
        }

    
    private func fetchUserRole(userID: String) {
            dbRef.child("users/\(userID)").getData { error, snapshot in
                if let error = error {
                    print("Error fetching user role: \(error.localizedDescription)")
                    self.destination = .signIn  // Fallback to Sign In on error.
                    return
                }

                if let role = snapshot?.childSnapshot(forPath: "userRole").value as? String {
                    DispatchQueue.main.async {
                        switch role {
                        case "admin":
                            self.destination = .admin
                        case "moderator":
                            self.destination = .moderator
                        default:
                            self.destination = .user
                        }
                    }
                } else {
                    print("User role not found.")
                    self.destination = .signIn
                }
            }
        }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let _ = result {
                self.isLoggedIn = true
                completion(true, nil)
            } else if let error = error {
                self.isLoggedIn = false
                completion(false, error)
            }
        }
    }

    func sendPasswordReset(email: String, completion: @escaping (Bool, Error?) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func signOut() {
        try? auth.signOut()
        self.isLoggedIn = false
    }

    func fetchUserData(completion: @escaping (DataSnapshot?) -> Void) {
        dbRef.child("users").observeSingleEvent(of: .value) { snapshot in
            completion(snapshot)
        }
    }

    func saveUserData(userId: String, data: [String: Any]) {
        dbRef.child("users").child(userId).setValue(data)
    }
}

