//
//  BluetoothManager.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import CoreBluetooth
import Combine
import Foundation

@MainActor
final class BluetoothManager: NSObject, ObservableObject {
    @Published private(set) var nearbyDevices: [TrackedDevice] = []
    @Published private(set) var bluetoothState: CBManagerState = .unknown
    @Published private(set) var isScanning = false

    private var centralManager: CBCentralManager!
    private var devicesByID: [UUID: TrackedDevice] = [:]

    override init() {
        super.init()

        centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
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
    }

    func toggleTrusted(for device: TrackedDevice) {
        device.isTrusted.toggle()
        nearbyDevices.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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

        if let existingDevice = devicesByID[deviceID] {
            existingDevice.name = deviceName
            existingDevice.lastSeen = .now
            existingDevice.latestRSSI = signalStrength
        } else {
            let newDevice = TrackedDevice(
                id: deviceID,
                name: deviceName,
                latestRSSI: signalStrength
            )

            devicesByID[deviceID] = newDevice
        }

        nearbyDevices = devicesByID.values.sorted {
            $0.latestRSSI > $1.latestRSSI
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
