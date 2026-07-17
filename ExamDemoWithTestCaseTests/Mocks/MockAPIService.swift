//
//  MockAPIService.swift
//  ExamDemoWithTestCase
//
//  Created by Ankit on 16/07/26.
//

import Foundation
@testable import ExamDemoWithTestCase //app target ke internal classes ko test target me accessible banata hai.
class MockAPIService: APIServiceProtocol {

    var shouldReturnError = false

    func request<T: Decodable>(endPoint: APIEndPoint, method: HttpMethod, param: [String: Any]?, accessToken:String?,responseType: T.Type) async throws -> T {

        if shouldReturnError {
            throw APIError.serverError("API Failed")
        }

        let users = [
            User(id: 1, name: "Ankit", email: ""),
            User(id: 2, name: "Rahul", email: "")
        ]

        return users as! T
    }
}
