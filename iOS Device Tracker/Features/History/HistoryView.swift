//
//  HistoryView.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \TrackedDevice.lastSeen, order: .reverse)
    private var trackedDevices: [TrackedDevice]

    var body: some View {
        Group {
            if trackedDevices.isEmpty {
                ContentUnavailableView(
                    "No History Yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Devices will appear here after you scan for them.")
                )
            } else {
                List(trackedDevices) { device in
                    NavigationLink {
                        DeviceDetailView(device: device)
                    } label: {
                        HistoryDeviceRow(device: device)
                    }
                }
            }
        }
        .navigationTitle("Device History")
    }
}

private struct HistoryDeviceRow: View {
    let device: TrackedDevice

    var body: some View {
        HStack(spacing: 12) {
            Image(
                systemName: device.isTrusted
                    ? "checkmark.shield.fill"
                    : "dot.radiowaves.left.and.right"
            )
            .foregroundStyle(device.isTrusted ? .green : .blue)

            VStack(alignment: .leading, spacing: 5) {
                Text(device.name)
                    .font(.headline)

                Text("Seen \(device.sightingCount) \(device.sightingCount == 1 ? "time" : "times")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(
                    "Last seen \(device.lastSeen, format: .relative(presentation: .named))"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if device.isTrusted {
                Text("Trusted")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(for: TrackedDevice.self, inMemory: true)
}
