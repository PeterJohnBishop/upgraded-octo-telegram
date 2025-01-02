//
//  swiftui_upgraded_octo_telegramApp.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/1/25.
//

import SwiftUI
import SwiftData

@main
struct swiftui_upgraded_octo_telegramApp: App {
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
        }
        .modelContainer(sharedModelContainer)
    }
}
