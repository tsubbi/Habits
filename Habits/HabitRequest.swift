//
//  HabitRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import Foundation

struct HabitRequest: APIRequest {
    typealias Response = [String: Habit]
    
    var habitName: String?
    var path: String { "/habits" }
}
