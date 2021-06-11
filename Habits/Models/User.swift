//
//  User.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import Foundation

struct User {
    let id: String
    let name: String
    let color: Color?
    let bio: String?
}

extension User: Codable { }

extension User: Hashable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
