//
//  AppUser.swift
//  IOSspecimencopy1
//
//  Created by Subash Gaddam on 2024-10-30.
//

import Foundation

struct AppUser: Identifiable {
    let id: String
    let userName: String
    let userRole: String
    let isBanned: Bool
    let reports: Int

    init(id: String, data: [String: Any]) {
        self.id = id
        self.userName = data["userName"] as? String ?? "Unknown User"
        self.userRole = data["userRole"] as? String ?? "user"
        self.isBanned = data["isBanned"] as? Bool ?? false
        self.reports = data["reports"] as? Int ?? 0
    }
}
