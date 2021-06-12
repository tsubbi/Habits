//
//  ImageRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-11.
//

import UIKit

struct ImageRequest: APIRequest {
    typealias Response = UIImage
    var imageID: String
    var path: String { "/images/" + imageID }
}
