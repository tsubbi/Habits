//
//  HabitLeadStatisticsRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct HabitLeadStatisticsRequest: APIRequest {
    typealias Response = UserStatistics

    var userID: String
    var path: String { "/userLeadingStats/\(userID)" }
}
