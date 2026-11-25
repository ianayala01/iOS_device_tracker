//
//  DeviceObservation.swift
//  iOS Device Tracker
//
//  Created by patron on 11/25/26.
//

import Foundation
import SwiftData

@Model
final class DeviceObservation: Identifiable{
    var id: UUID
    var deviceID: UUID
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var rssi: Int
    
    init(
        id: UUID = UUID(),
        deviceID: UUID,
        timestamp: Date = .now,
        latitude: Double,
        longitude: Double,
        rssi: Int
    ) {
        self.id = id
        self.deviceID = deviceID
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.rssi = rssi
    }
}
