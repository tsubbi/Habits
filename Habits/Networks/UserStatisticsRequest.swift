//
//  UserStatisticsRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct UserStatisticsRequest: APIRequest {
    typealias Response = [UserStatistics]

    var userIDs: [String]?
    var path: String { "/userStats" }
    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        } else {
            return nil
        }
    }
}
