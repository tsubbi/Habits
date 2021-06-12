//
//  UserStatistics.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable { }

