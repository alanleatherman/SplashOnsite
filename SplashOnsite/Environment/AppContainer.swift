//
//  AppContainer.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import Foundation
import SwiftUI

struct AppContainer {
    let appState: AppState
    let services: Services
    
    init(appState: AppState = AppState(), services: Services) {
        self.appState = appState
        self.services = services
    }
    
    // MARK: - Setup on App Start (Async Initializations)
    func setup() async {
    }
}

struct Services {
    let networkService: NetworkService
    
    static var stub: Self {
        .init(
            networkService: NetworkService()
        )
    }
}

// MARK: - Environment Keys

private struct AppStateKey: EnvironmentKey {
    static let defaultValue = AppState()
}

private struct ServicesKey: EnvironmentKey {
    static let defaultValue = Services.stub
}

// MARK: - Environment Values Extensions

extension EnvironmentValues {
    
    var appState: AppState {
        get { self[AppStateKey.self] }
        set { self[AppStateKey.self] = newValue }
    }
    
    var services: Services {
        get { self[ServicesKey.self] }
        set { self[ServicesKey.self] = newValue }
    }
}

// MARK: - View Extension for Dependency Injection

extension View {
    func inject(_ container: AppContainer) -> some View {
        self.environment(\.appState, container.appState)
            .environment(\.services, container.services)
    }
}
