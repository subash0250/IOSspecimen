//////
//////  Untitled.swift
//////  IOSspecimencopy1
//////
//////  Created by Subash Gaddam on 2024-10-25.
//////
////
//import SwiftUI
//import FirebaseDatabase
//import Firebase
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
//                  
//
//                    GridView {
//                        SummaryCard(title: "Active Users", value: "\(activeUsers)", icon: "person.3") {
//                            UserManagementTab()
//                        }
//                        SummaryCard(title: "Total Posts", value: "\(totalPosts)", icon: "note.text") {
//                            PostsScreenAdmin()
//                        }
//                        SummaryCard(title: "Flagged Content", value: "\(flaggedContent)", icon: "flag") {
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
//private func fetchDashboardData() {
//        let group = DispatchGroup()
//
//        group.enter()
//        dbRef.child("users").observeSingleEvent(of: .value) { snapshot in
//            DispatchQueue.main.async {
//                activeUsers = Int(snapshot.childrenCount)
//            }
//            group.leave()
//        }
//
//        group.enter()
//        dbRef.child("posts").observeSingleEvent(of: .value) { snapshot in
//            DispatchQueue.main.async {
//                totalPosts = Int(snapshot.childrenCount)
//            }
//            group.leave()
//        }
//
//        group.enter()
//        dbRef.child("flaggedPosts").observeSingleEvent(of: .value) { snapshot in
//            DispatchQueue.main.async {
//                flaggedContent = Int(snapshot.childrenCount)
//            }
//            group.leave()
//        }
//
//    }
//
//}
//
//// Updated SummaryCard with @ViewBuilder
//struct SummaryCard<Content: View>: View {
//    var title: String
//    var value: String
//    var icon: String
//    @ViewBuilder var content: () -> Content
//
//    var body: some View {
//        NavigationLink(destination: content()) {
//            VStack {
//                Image(systemName: icon)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.indigo)
//                Text(value)
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//            
//                Text(title)
//                    .font(.headline)
//                
//
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(12)
//            .shadow(radius: 4)
//            .foregroundColor(.blue)
//
//            
//        }
//    }
//}
//
//struct GridView<Content: View>: View {
//    @ViewBuilder let content: () -> Content
//
//    var body: some View {
//        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
//            content()
//        }
//    }
//}
//
//
//
//struct AdminHomeTab_Previews: PreviewProvider {
//    static var previews: some View {
//        AdminHomeTab()
//    }
//}
//
import SwiftUI
import FirebaseDatabase

struct AdminHomeTab: View {
    @State private var activeUsers: Int = 0
    @State private var totalPosts: Int = 0
    @State private var flaggedContent: Int = 0
    
    private var dbRef = Database.database().reference()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Overview")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        SummaryCard(
                            title: "Active Users",
                            value: "\(activeUsers)",
                            icon: "person.3.fill",
                            destination: UserManagementTab()
                        )
                        SummaryCard(
                            title: "Total Posts",
                            value: "\(totalPosts)",
                            icon: "doc.text.fill",
                            destination: PostsScreenAdmin()
                        )
                        SummaryCard(
                            title: "Flagged Content",
                            value: "\(flaggedContent)",
                            icon: "flag.fill",
                            destination: ContentModerationScreen()
                        )
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Home")
        }
        .onAppear {
            fetchDashboardData()
        }
    }
    
    private func fetchDashboardData() {
        dbRef.child("users").observeSingleEvent(of: .value) { snapshot in
            activeUsers = Int(snapshot.childrenCount)
        }
        
        dbRef.child("posts").observeSingleEvent(of: .value) { snapshot in
            totalPosts = Int(snapshot.childrenCount)
        }
        
        dbRef.child("flaggedPosts").observeSingleEvent(of: .value) { snapshot in
            flaggedContent = Int(snapshot.childrenCount)
        }
    }
}

struct SummaryCard<Destination: View>: View {
    let title: String
    let value: String
    let icon: String
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.subheadline)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
            .foregroundColor(.blue)
        }
    }
}


// Preview for AdminHomeTab
struct AdminHomeTab_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomeTab()
    }
}
