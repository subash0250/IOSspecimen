////
////  Untitled.swift
////  IOSspecimencopy1
////
////  Created by Subash Gaddam on 2024-10-25.
////
//
//import SwiftUI
//import FirebaseDatabase
//
//struct AdminHomeTab: View {
//    @State private var activeUsers: Int = 0
//    @State private var totalPosts: Int = 0
//    @State private var flaggedContent: Int = 0
//    
//    private let dbRef = Database.database().reference()
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    Text("Overview")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                    
//                    GridView {
//                        SummaryCard(title: "Active Users", value: "\(activeUsers)", icon: "person.3") {
//                            // Navigate to User Management
//                            // Replace with your actual view
//                            UserManagementTab()
//                        }
//                        SummaryCard(title: "Total Posts", value: "\(totalPosts)", icon: "note.text") {
//                            // Navigate to Posts Screen
//                            // Replace with your actual view
//                            PostsScreenAdmin()
//                        }
//                        SummaryCard(title: "Flagged Content", value: "\(flaggedContent)", icon: "flag") {
//                            // Navigate to Content Moderation
//                            // Replace with your actual view
//                            ContentModerationScreen()
//                        }
//                    }
//                    .padding()
//                }
//                .padding()
//                .onAppear {
//                    fetchDashboardData()
//                }
//            }
//            .navigationTitle("Home")
//        }
//    }
//
//    private func fetchDashboardData() {
//        let group = DispatchGroup()
//        
//        group.enter()
//        dbRef.child("users").observeSingleEvent(of: .value) { snapshot in
//            activeUsers = Int(snapshot.childrenCount)
//            group.leave()
//        }
//        
//        group.enter()
//        dbRef.child("posts").observeSingleEvent(of: .value) { snapshot in
//            totalPosts = Int(snapshot.childrenCount)
//            group.leave()
//        }
//        
//        group.enter()
//        dbRef.child("flaggedPosts").observeSingleEvent(of: .value) { snapshot in
//            flaggedContent = Int(snapshot.childrenCount)
//            group.leave()
//        }
//
//        group.notify(queue: .main) {
//            // Update UI if needed after all data is fetched
//        }
//    }
//}
//
//struct SummaryCard: View {
//    var title: String
//    var value: String
//    var icon: String
//    var onTap: () -> Void
//
//    var body: some View {
//        Button(action: onTap) {
//            VStack {
//                Image(systemName: icon)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.blue)
//                Text(value)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                Text(title)
//                    .font(.headline)
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(radius: 4)
//        }
//    }
//}
//
//// Grid View for displaying the summary cards
//struct GridView<Content: View>: View {
//    let content: () -> Content
//
//    var body: some View {
//        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
//            content()
//        }
//    }
//}
//
//
//struct AdminHomeTab_Previews: PreviewProvider {
//    static var previews: some View {
//        AdminHomeTab()
//    }
//}
