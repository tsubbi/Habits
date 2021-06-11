//
//  HabitStatistics.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCount: [UserCount]
}

extension HabitStatistics: Codable { }
