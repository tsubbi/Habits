//
//  LoggedHabit.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

extension LoggedHabit: Codable { }
