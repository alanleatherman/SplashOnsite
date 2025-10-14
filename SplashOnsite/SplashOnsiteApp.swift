//
//  SplashOnsiteApp.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import SwiftUI
import SwiftData

@main
struct SplashOnsiteApp: App {
    @State private var appContainer: AppContainer?

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .inject(getAppContainer())
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func getAppContainer() -> AppContainer {
        if let container = appContainer {
            return container
        }
        
        let container = AppEnvironment.bootstrap().appContainer
        appContainer = container
        return container
    }
}
