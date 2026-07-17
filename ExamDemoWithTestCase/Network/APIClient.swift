//
//  APIClient.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//
import Foundation
class APIClient: APIServiceProtocol {
    
    func request<T: Decodable>(endPoint: APIEndPoint, method: HttpMethod, param: [String: Any]?, accessToken:String?,responseType: T.Type) async throws -> T {
        
        let urlString = BaseUrl + endPoint.rawValue
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json",
                         forHTTPHeaderField: "Content-Type")
        if let accessToken = accessToken{
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        if let parameter = param{
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
            } catch(let error) {
                throw APIError.serverError(error.localizedDescription)
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid Response")
        }
        switch response.statusCode {
        case 200...299 :
            do{
                return try JSONDecoder().decode(T.self, from: data)
            }catch{
                throw APIError.decodingError
            }
        case 401:
            throw APIError.sessionExpired
        case 403:
            throw APIError.forbidden
        default:
            throw APIError.serverError("HTTP Status Code: \(response.statusCode)")
        }
        
        
    }
}
