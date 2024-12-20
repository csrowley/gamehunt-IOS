//
//  gameknowledgeApp.swift
//  gameknowledge
//
//  Created by Chris Rowley on 9/15/24.
//

import SwiftUI
import SwiftData

@main
struct gameknowledgeApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SearchTerms.self,
            SearchData.self
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
        }
        .modelContainer(sharedModelContainer)
    }
}
