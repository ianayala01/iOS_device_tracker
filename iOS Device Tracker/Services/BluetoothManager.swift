//
//  BluetoothManager.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import CoreBluetooth
import Combine
import Foundation
import SwiftData

/// Owns the Core Bluetooth scanner and publishes the devices found by it.
@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var nearbyDevices: [TrackedDevice] = []
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var isScanning = false

    private var centralManager: CBCentralManager!
    private var devicesByID: [UUID: TrackedDevice] = [:]
    private var modelContext: ModelContext?

    override init() {
        super.init()

        centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext

    }

    func startScanning() {
        guard bluetoothState == .poweredOn else { return }

        devicesByID.removeAll()
        nearbyDevices = []
        isScanning = true

        // nil means discover any discoverable BLE peripheral.
        centralManager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true]
        )
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        saveChanges()
    }

    func toggleTrusted(for device: TrackedDevice) {
        device.isTrusted.toggle()
        saveChanges()
    }

    private func updateDevice(
        peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        let deviceID = peripheral.identifier
        let advertisedName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        let deviceName = advertisedName ?? peripheral.name ?? "Unknown Device"
        let signalStrength = rssi.intValue

        let device: TrackedDevice
        var isFirstDiscoveryThisScan = false

        if let liveDevice = devicesByID[deviceID] {
            device = liveDevice
        } else if let savedDevice = savedDevice(withID: deviceID) {
            device = savedDevice
            devicesByID[deviceID] = savedDevice
            isFirstDiscoveryThisScan = true
        } else {
            let newDevice = TrackedDevice(
                id: deviceID,
                name: deviceName,
                firstSeen: .now,
                lastSeen: .now,
                sightingCount: 0,
                latestRSSI: signalStrength
            )

            modelContext?.insert(newDevice)
            devicesByID[deviceID] = newDevice
            device = newDevice
            isFirstDiscoveryThisScan = true
        }

        // Update the live information without changing the saved trust choice.
        device.name = deviceName
        device.lastSeen = .now
        device.latestRSSI = signalStrength

        if isFirstDiscoveryThisScan {
            device.sightingCount += 1
        }

        nearbyDevices = devicesByID.values.sorted {
            $0.latestRSSI > $1.latestRSSI
        }

        // Save newly discovered devices immediately. RSSI and last-seen changes
        // are saved when scanning stops to avoid writing for every advertisement.
        if isFirstDiscoveryThisScan && device.sightingCount == 1 {
            saveChanges()
        }
    }

    private func savedDevice(withID id: UUID) -> TrackedDevice? {
        guard let modelContext else { return nil }

        let descriptor = FetchDescriptor<TrackedDevice>(
            predicate: #Predicate { device in
                device.id == id
            }
        )

        return try? modelContext.fetch(descriptor).first
    }

    private func saveChanges() {
        do {
            try modelContext?.save()
        } catch {
            print("Could not save tracked devices: \(error)")
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor [weak self] in
            self?.bluetoothState = central.state
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        Task { @MainActor [weak self] in
            self?.updateDevice(
                peripheral: peripheral,
                advertisementData: advertisementData,
                rssi: RSSI
            )
        }
    }
}
