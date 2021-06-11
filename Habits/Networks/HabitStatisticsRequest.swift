//
//  HabitStatisticsRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct HabitStatisticsRequest: APIRequest {
    typealias Response = [HabitStatistics]

    var habitNames: [String]?

    var path: String { "/habitStats" }

    var queryItems: [URLQueryItem]? {
        if let habitNames = habitNames {
            return [URLQueryItem(name: "names", value: habitNames.joined(separator: ","))]
        } else {
            return nil
        }
    }
}
