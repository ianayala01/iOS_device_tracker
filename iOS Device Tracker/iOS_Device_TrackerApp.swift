//
//  iOS_Device_TrackerApp.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import SwiftUI
import SwiftData

@main
struct iOS_Device_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrackedDevice.self,
            DeviceObservation.self
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
            NearbyDevicesView()
        }
        .modelContainer(sharedModelContainer)
    }
}
