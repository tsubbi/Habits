//
//  UserRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import Foundation

struct UserRequest: APIRequest {
    typealias Response = [String: User]
    
    var path: String { "/users" }
}
