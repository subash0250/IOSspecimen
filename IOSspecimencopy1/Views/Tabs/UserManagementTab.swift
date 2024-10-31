//
//  UserManagementTab.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-25.
//

//import SwiftUI
//
//struct UserManagementTab: View {
//    var body: some View {
//        Text("User management Home")
//    }
//}
//import SwiftUI
//import Firebase
//import FirebaseDatabase
//
//struct UserManagementTab: View {
//    @ObservedObject private var viewModel = UserManagementViewModel()
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if viewModel.isLoading {
//                    ProgressView("Loading users...")
//                } else if viewModel.users.isEmpty {
//                    Text("No users available")
//                        .foregroundColor(.gray)
//                        .font(.headline)
//                } else {
//                    List(viewModel.users, id: \.id) { user in
//                        HStack {
//                            Circle()
//                                .fill(Color.blue)
//                                .frame(width: 40, height: 40)
//                                .overlay(
//                                    Text(String(user.userName.prefix(1)))
//                                        .foregroundColor(.white)
//                                )
//
//                            VStack(alignment: .leading) {
//                                Text(user.userName)
//                                    .font(.headline)
//                                Text("Role: \(user.userRole) | Reports: \(user.reports)")
//                                    .font(.subheadline)
//                                    .foregroundColor(.gray)
//                            }
//
//                            Spacer()
//
//                            Menu {
//                                Button(user.isBanned ? "Unban User" : "Ban User") {
//                                    viewModel.toggleBanStatus(user: user)
//                                }
//                                Button(user.userRole == "moderator" ? "Revoke Moderator" : "Assign Moderator") {
//                                    viewModel.updateUserRole(user: user, newRole: user.userRole == "moderator" ? "user" : "moderator")
//                                }
//                                Button("Remove User") {
//                                    viewModel.removeUser(user: user)
//                                }
//                                Button("View Reports & History") {
//                                    viewModel.viewUserHistory(userId: user.id)
//                                }
//                            } label: {
//                                Image(systemName: "ellipsis.circle")
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("User Management")
//            .onAppear {
//                viewModel.fetchUsers()
//            }
////            .alert(item: $viewModel.error) { error in
////                Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("OK")))
////            }
//        }
//    }
//}

import SwiftUI
import FirebaseAuth
import Firebase


import Firebase
import FirebaseDatabase
import FirebaseAuth

struct UserManagementTab: View {
    @ObservedObject private var viewModel = UserManagementViewModel()
    @State private var selectedUserId: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else if viewModel.users.isEmpty {
                    Text("No users available")
                        .foregroundColor(.gray)
                        .font(.headline)
                } else {
                    List(viewModel.users, id: \.id) { user in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(user.userName.prefix(1)))
                                        .foregroundColor(.white)
                                )

                            VStack(alignment: .leading) {
                                Text(user.userName)
                                    .font(.headline)
                                Text("Role: \(user.userRole) | Reports: \(user.reports)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Menu {
                                Button(user.isBanned ? "Unban User" : "Ban User") {
                                    viewModel.handleUserAction(action: .ban, user: user)
                                }
                                Button(user.userRole == "moderator" ? "Revoke Moderator" : "Assign Moderator") {
                                    let newRole = user.userRole == "moderator" ? "user" : "moderator"
                                    viewModel.handleUserAction(action: .updateRole(newRole), user: user)
                                }
                                Button("Remove User") {
                                    viewModel.handleUserAction(action: .remove, user: user)
                                }
                                Button("View Reports & History") {
                                                                    selectedUserId = user.id // Set userId to trigger navigation
                                                                }
                            }
                            label: {
                                Image(systemName: "ellipsis.circle")
                            }.foregroundColor(.black)
                        }
                    }
                }
            }
            .navigationTitle("User Management")
            .onAppear {
                viewModel.fetchUsers()
            }
            .alert(item: $viewModel.error) { identifiableError in
                           Alert(
                               title: Text("Error"),
                               message: Text(identifiableError.error.localizedDescription),
                               dismissButton: .default(Text("OK"))
                           )
                       }
            .background(
                        NavigationLink(
                            destination: UserHistoryView(userId: selectedUserId ?? ""),
                            isActive: Binding(
                                get: { selectedUserId != nil },
                                set: { if !$0 { selectedUserId = nil } }
                            )
                        ) {
                            EmptyView()
                        }
                    )
        }
    }
}



struct IdentifiableError: Identifiable {
    let id = UUID()
    let error: Error
}
