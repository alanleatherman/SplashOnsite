//
//  AppEnvironment.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import Foundation
import SwiftData

@MainActor
struct AppEnvironment {
    let option: Option
    let appContainer: AppContainer
    
    enum Option: String {
        case debug
        //case preview
        //case mock
        case production
    }
    
    static let current: Option = {
        #if DEBUG
        return .debug         // Debug Scheme → Real API
        #else
        return .production    // Release Scheme → Real API
        #endif
        
        /*
         #if PREVIEW
         return .preview        // SwiftUI Previews → Mock Data
         #elseif MOCK_DATA
         return .mock          // Mock Scheme → Mock Data
         */
    }()
}


extension AppEnvironment {
    static func bootstrap(_ optionOverride: AppEnvironment.Option? = nil) -> AppEnvironment {
        let option = optionOverride ?? AppEnvironment.current
        
        switch option {
        case .debug:
            print("Using Debug API Repository")
            return createRealEnvironment(isDebug: true)
        case .production:
            print("Using Prod API Repository")
            return createRealEnvironment(isDebug: false)
        }
    }
    
    
    // private static func createMockEnvironment() -> AppEnvironment { ... }
    
    private static func createRealEnvironment(isDebug: Bool) -> AppEnvironment {
        let appState = AppState()
        let services = createRealServices(isDebug: isDebug)
        let container = AppContainer(appState: appState, services: services)
        
        Task {
            await container.setup()
        }
        
        return AppEnvironment(option: isDebug ? .debug : .production,
                              appContainer: container)
    }
    
    private static func createRealServices(isDebug: Bool) -> Services {
        let networkService = NetworkService()
        // Add debug logging: if isDebug { networkService.enableLogging() }
        // Add other services
        return Services(networkService: networkService)
    }
    
}
