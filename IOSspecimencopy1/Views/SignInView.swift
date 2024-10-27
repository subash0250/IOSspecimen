//
//  SignInView.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-13.
//
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailError = ""
    @State private var passwordError = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode

    private let auth = Auth.auth()
    private let dbRef = Database.database().reference()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                }
                
                TextField("Email", text: $email)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.top)
                    .overlay(
                        Text(emailError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 65), alignment: .topLeading
                    )
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .overlay(
                        Text(passwordError)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 65), alignment: .topLeading
                    )
                
                Button(action: signIn) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            
                HStack {
                    NavigationLink("Forgot password", destination: ForgotPasswordView())
                    .padding(.top,15)
                }
                
                   

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                }

                Spacer()

                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Sign Up", destination: SignUpView())
                }
            }
            .padding()
        }
    }

    private func signIn() {
        
        emailError = ""
        passwordError = ""
        errorMessage = ""
        
       
        guard !email.isEmpty else {
            emailError = "Email cannot be empty"
            return
        }

        guard isValidEmail(email) else {
            emailError = "Enter a valid email address"
            return
        }

        guard password.count >= 6 else {
            passwordError = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        auth.signIn(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                           errorMessage = error.localizedDescription
                       } else if let user = result?.user {
                           
                           navigateBasedOnRole(userID: user.uid)
                       }
                   }
    }

    private func navigateBasedOnRole(userID: String) {
           dbRef.child("users/\(userID)").getData { error, snapshot in
               guard error == nil else {
                   self.errorMessage = "Failed to retrieve user role. Please try again."
                   return
               }

               if let role = snapshot?.childSnapshot(forPath: "userRole").value as? String {
                   DispatchQueue.main.async {
                       switch role {
                       case "admin":
                           navigateTo(view: AdminHomeScreen())
                       case "moderator":
                           navigateTo(view: ModeratorHomeScreen())
                       default:
                           navigateTo(view: HomeView())
                       }
                   }
               } else {
                   self.errorMessage = "User role not found. Please contact support."
               }
           }
       }

    private func navigateTo<Destination: View>(view: Destination) {
           let view = AnyView(view)
           let rootView = UIHostingController(rootView: view)

           if let window = UIApplication.shared.windows.first {
               window.rootViewController = rootView
               window.makeKeyAndVisible()
           }
       }


    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\\.[a-zA-Z]+$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}





