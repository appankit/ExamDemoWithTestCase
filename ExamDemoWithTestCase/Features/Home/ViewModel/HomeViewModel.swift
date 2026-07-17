//
//  HomeViewModel.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//

import Foundation
@MainActor
class HomeViewModel{
    var apiClient: APIServiceProtocol
    var eventHandler: ((Event) -> Void)?
    var userData: [User]?
    
    init(apiClient: APIServiceProtocol) {
        self.apiClient = apiClient
    }
    
    func getUserData() async {
        eventHandler?(.loading(true))
        defer {
            eventHandler?(.loading(false))
        }
        do {
            let response = try await apiClient.request(endPoint: .getUserData, method: .get, param: nil, accessToken: nil, responseType: [User].self)
            userData = response
            eventHandler?(.dataLoaded)
        }catch(let error){
            eventHandler?(.error(error.localizedDescription))
            print(error.localizedDescription)
        }
    }
}

enum Event: Equatable{
    case dataLoaded
    case error(String)
    case loading(Bool)

}
