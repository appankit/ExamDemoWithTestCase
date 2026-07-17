//
//  HomeViewModelTests.swift
//  ExamDemoWithTestCase
//
//  Created by Ankit on 16/07/26.
//

import XCTest
@testable import ExamDemoWithTestCase
@MainActor
final class HomeViewModelTests: XCTestCase {
    
    func test_getUserData_success() async {
        let mock = MockAPIService()
        let vm = HomeViewModel(apiClient: mock)
        
        await vm.getUserData()
        
        XCTAssertEqual(vm.userData?.count, 2)
    }
    
    func test_getUserData_whenAPIThrows_shouldReturnError() async {
        //Arrange
        var receivedError: String?
        let mock = MockAPIService()
        mock.shouldReturnError = true
        
        let vm = HomeViewModel(apiClient: mock)
        vm.eventHandler = { event in
            if case .error(let error) = event {
                receivedError = error
            }
        }
        
        //Act
        await vm.getUserData()
        
        //Assert
        XCTAssertEqual(receivedError, "API Failed")
        
    }
    
    func test_getUserData_API_SuccesEven() async {
        //Arrange
        var receivedEvents: [Event] = []
        let mock = MockAPIService()
    //    mock.shouldReturnError = true
        
        let vm = HomeViewModel(apiClient: mock)
        vm.eventHandler = { event in
            receivedEvents.append(event)
        }
        
        //Act
        await vm.getUserData()
        
        //Assert
        XCTAssertEqual(receivedEvents, [.loading(true),.dataLoaded, .loading(false)])
        
    }
    
    func test_getUserData_API_FailEven() async {
        //Arrange
        var receivedEvents: [Event] = []
        let mock = MockAPIService()
       mock.shouldReturnError = true
        
        let vm = HomeViewModel(apiClient: mock)
        vm.eventHandler = { event in
            receivedEvents.append(event)
        }
        
        //Act
        await vm.getUserData()
        
        //Assert
        XCTAssertEqual(receivedEvents, [.loading(true),.error("API Failed1"), .loading(false)])
        
    }
    
}
