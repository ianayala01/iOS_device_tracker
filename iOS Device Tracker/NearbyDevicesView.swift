//
//  ContentView.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import SwiftUI
import SwiftData
import CoreBluetooth

struct NearbyDevicesView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                bluetoothStatusBanner
                    .padding(.horizontal)
                    .padding(.vertical, 12)

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
            }
            .navigationTitle("Nearby Devices")
            .toolbar {
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
            .onAppear {
                bluetoothManager.configure(with: modelContext)

            }
        }
    }

    private var bluetoothStatusBanner: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(bluetoothStateDescription)
                .font(.subheadline.weight(.semibold))

            Spacer()

            if bluetoothManager.isScanning {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .foregroundStyle(statusColor)
        .background(statusColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private var statusColor: Color {
        switch bluetoothManager.bluetoothState {
        case .poweredOn:
            return bluetoothManager.isScanning ? .blue : .green
        case .poweredOff, .unauthorized, .unsupported:
            return .red
        case .resetting, .unknown:
            return .orange
        @unknown default:
            return .orange
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
            return "Unknown Bluetooth State"
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
