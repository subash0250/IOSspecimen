//
//  SignUpView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseAuth

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var selectedRole: String = "user"
    @State private var roles: [String] = ["user", "moderator", "admin"]
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                TextField("Bio", text: $bio)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                
                Picker("Select Role", selection: $selectedRole) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(.segmented)
                .padding(8)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: signUp) {
                    Text(isLoading ? "Signing Up..." : "Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.black)
                        .cornerRadius(8)
                }
                .disabled(isLoading)
                
                NavigationLink(destination: SignInView()) {
                    Text("Already have an account? Sign In")
                }
                .padding(8)
            }
            .padding()
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func signUp() {
        guard !isLoading else { return }
        errorMessage = nil
        
        guard validateForm()
        else {
            return
        }
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            guard let userId = result?.user.uid else { return }
            let userInfo: [String: Any] = [
                "userBio": bio,
                "userCreatedAt": Date().description,
                "userEmail": email,
                "userName": name,
                "userProfileImage": "https://firebasestorage.googleapis.com/v0/b/conectivity-app.appspot.com/o/profile_images%2Fdefault_profile.png?alt=media&token=1f649470-3a12-45a3-90b7-eb045a37939c",
                "userRole": selectedRole,
                "userStatus": "active",
                "isBanned": false,
                "reports": 0
            ]
            
            let ref = Database.database().reference()
            ref.child("users").child(userId).setValue(userInfo) { error, _ in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    
                }
                self.isLoading = false
            }
        }
    }
    private func validateForm() -> Bool {
            if name.isEmpty {
                errorMessage = "Please enter your name"
                return false
            }
            if email.isEmpty {
                errorMessage = "Please enter your email"
                return false
            }
            if !isValidEmail(email) {
                errorMessage = "Please enter a valid email"
                return false
            }
            if password.isEmpty {
                errorMessage = "Please enter a password"
                return false
            }
            if password.count < 6 {
                errorMessage = "Password must be at least 6 characters"
                return false
            }
            if selectedRole.isEmpty {
                errorMessage = "Please select a role"
                return false
            }
        if bio.isEmpty {
            errorMessage = "Please enter a bio"
            return false
        }
            return true
        }
        
        private func isValidEmail(_ email: String) -> Bool {
            let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let regex = NSPredicate(format: "SELF MATCHES %@", emailPattern)
            return regex.evaluate(with: email)
        }
}




