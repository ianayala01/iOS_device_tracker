//
//  ContentView.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import SwiftUI
import CoreBluetooth

struct NearbyDevicesView: View {
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationStack {
            Group {
                if bluetoothManager.nearbyDevices.isEmpty {
                    ContentUnavailableView(
                        "No Devices Found",
                        systemImage: "dot.radiowaves.left.and.right",
                        description: Text("Start a scan to look for nearby Bluetooth devices.")
                    )
                } else {
                    List(bluetoothManager.nearbyDevices) { device in
                        DeviceRow(
                            device: device,
                            onToggleTrusted: {
                                bluetoothManager.toggleTrusted(for: device)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Nearby Devices")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(bluetoothStateDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    } label: {
                        Label(
                            bluetoothManager.isScanning ? "Stop" : "Scan",
                            systemImage: bluetoothManager.isScanning ? "stop.fill" : "arrow.clockwise"
                        )
                    }
                    .disabled(bluetoothManager.bluetoothState != .poweredOn)
                }
            }
        }
    }

    private var bluetoothStateDescription: String {
        switch bluetoothManager.bluetoothState {
        case .poweredOn:
            return bluetoothManager.isScanning ? "Scanning" : "Ready"
        case .poweredOff:
            return "Bluetooth Off"
        case .unauthorized:

            return "Permission Needed"
        case .unsupported:
            return "Unavailable"
        case .resetting:
            return "Resetting"
        case .unknown:
            return "Checking Bluetooth"
        @unknown default:
            return "Checking Bluetooth"
        }
    }
}

private struct DeviceRow: View {
    let device: TrackedDevice
    let onToggleTrusted: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: device.isTrusted ? "checkmark.shield.fill" : "dot.radiowaves.left.and.right")
                .foregroundStyle(device.isTrusted ? .green : .blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)

                Text("Signal: \(device.latestRSSI) dBm")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                onToggleTrusted()
            } label: {
                Text(device.isTrusted ? "Trusted" : "Trust")
                    .font(.caption.weight(.semibold))
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NearbyDevicesView()
}
