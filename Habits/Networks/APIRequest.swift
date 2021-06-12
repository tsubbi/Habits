//
//  APIRequest.swift
//  Habits
//
//  Created by Jamie Chen on 2021-06-10.
//

import Foundation
import UIKit

protocol APIRequest {
    associatedtype Response
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
}

extension APIRequest {
    var host: String { "localhost" }
    var port: Int { 8080 }
}

extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

enum ImageRequestError: Error {
    case couldNotInitializeFromData
}

extension APIRequest {
    var request: URLRequest {
        var components = URLComponents()
        
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

extension APIRequest where Response: Decodable {
    func send(completion: @escaping (Result<Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) {
            do {
                if let data = $0 {
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded))
                } else if let error = $2 {
                    completion(.failure(error))
                }
            } catch {  }
        }.resume()
    }
}

extension APIRequest where Response == UIImage {
    func send(completion: @escaping (Result<Self.Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) {
            guard $2 == nil else {
                completion(.failure($2!))
                return
            }
            
            if let data = $0, let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                completion(.failure(ImageRequestError.couldNotInitializeFromData))
            }
        }.resume()
    }
}
