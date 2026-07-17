//
//  APIServiceProtocol.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
}

enum APIEndPoint:String {
    case getUserData = "users"
}
enum APIError: LocalizedError {
    case invalidURL
    case network
    case decodingError
    case sessionExpired
    case forbidden
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .network:
            return "Network error occurred."
        case .decodingError:
            return "Failed to parse response."
        case .sessionExpired:
            return "Session expired."
        case .forbidden:
            return "You don’t have permission."
        case .serverError(let message):
            return message
        }
    }
}


var BaseUrl = "https://jsonplaceholder.typicode.com/"
 protocol APIServiceProtocol {
  //  func getData(completion: @escaping (Result<Data, Error>) -> Void)
     func request<T: Decodable>(endPoint:APIEndPoint, method:HttpMethod, param:[String:Any]?,accessToken: String?, responseType: T.Type) async throws -> T
    }
