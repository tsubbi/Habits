//
//  LogHabitRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import Foundation

struct LogHabitRequest: APIRequest {
    typealias Response = Void

    var trackedEvent: LoggedHabit

    var path: String { "/loggedHabit" }

    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(trackedEvent)
    }
}
