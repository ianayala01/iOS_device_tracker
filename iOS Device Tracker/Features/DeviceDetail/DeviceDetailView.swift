//
//  DeviceDetailView.swift
//  iOS Device Tracker
//
//  Created by patron on 11/25/26.
//

import SwiftData
import SwiftUI

struct DeviceDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var observations: [DeviceObservation]

    let device: TrackedDevice

    init(device: TrackedDevice) {
        self.device = device
        
        let deviceID = device.id
        
        _observations = Query(
            filter: #Predicate<DeviceObservation> { observation in
                observation.deviceID == deviceID
            },
            sort: \DeviceObservation.timestamp,
            order: .reverse
        )
    }
    
    var body: some View {
        List {
            Section("Device") {
                LabeledContent("Name", value: device.name)
                LabeledContent("Identifier", value: device.id.uuidString)
            }

            Section("Trust") {
                Button {
                    device.isTrusted.toggle()
                    saveChanges()
                } label: {
                    Label(
                        device.isTrusted ? "Remove Trusted Status" : "Mark as Trusted",
                        systemImage: device.isTrusted ? "checkmark.shield.fill" : "shield"
                    )
                }
                .foregroundStyle(device.isTrusted ? .orange : .blue)
            }

            Section("History") {
                LabeledContent("Sightings") {
                    Text("\(device.sightingCount)")
                }

                LabeledContent("First Seen") {
                    Text(device.firstSeen, format: .dateTime.month().day().year().hour().minute())
                }

                LabeledContent("Last Seen") {
                    Text(device.lastSeen, format: .dateTime.month().day().year().hour().minute())
                }
            }

            Section("Signal") {
                LabeledContent("Latest RSSI") {
                    Text("\(device.latestRSSI) dBm")
                }
            }
            
            Section("Observed Locations") {
                if observations.isEmpty {
                    Text("No location observations recorded yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(observations) { observation in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                "\(observation.latitude), \(observation.longitude)"
                            )
                            .font(.subheadline)
                            
                            Text(
                                observation.timestamp,
                                format: .dateTime
                                    .month()
                                    .day()
                                    .year()
                                    .hour()
                                    .minute()
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(device.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveChanges() {
        do {
            try modelContext.save()
        } catch {
            print("Could not save device trust status: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        DeviceDetailView(
            device: TrackedDevice(
                id: UUID(),
                name: "Example Device",
                isTrusted: true,
                sightingCount: 4,
                latestRSSI: -52
            )
        )
    }
    .modelContainer(for: [TrackedDevice.self, DeviceObservation.self], inMemory: true)
}
