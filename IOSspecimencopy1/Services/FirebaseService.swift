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
    private var dbRef = Database.database().reference()

    init() {
        _ = Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                self.isLoggedIn = true
            } else {
                self.isLoggedIn = false
            }
        }
    }


    func signIn(email: String, password: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = result {
                self.isLoggedIn = true
                completion(true, nil)
            } else if let error = error {
                self.isLoggedIn = false
                completion(false, error)
            }
        }
    }

    // Sign up with additional user information
        func signUp(email: String, password: String, userName: String, userBio: String, userRole: String, userProfileImage: String?, completion: @escaping (Bool, Error?) -> Void) {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let user = result?.user {
                    let userData: [String: Any] = [
                        "userEmail": email,
                        "userName": userName,
                        "userBio": userBio,
                        "userProfileImage": userProfileImage ?? "defaultProfileImageURL",
                        "userRole": userRole,
                        "userStatus": "active",
                        "userCreatedAt": [".sv": "timestamp"] // Use server timestamp
                    ]
                    
                    self.dbRef.child("users").child(user.uid).setValue(userData) { error, _ in
                        completion(error == nil, error)
                    }
                } else if let error = error {
                    completion(false, error)
                }
            }
        }

    func sendPasswordReset(email: String, completion: @escaping (Bool, Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
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

