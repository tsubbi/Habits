//
//  UserCount.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct UserCount {
    let user: User
    let count: Int
}

extension UserCount: Codable { }

extension UserCount: Hashable { }
