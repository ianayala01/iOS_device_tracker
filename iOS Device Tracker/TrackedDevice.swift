//
//  Item.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import Foundation
import SwiftData

@Model
final class TrackedDevice {
    var id: UUID
    
    var name: String
    var isTrusted: Bool
    var firstSeen: Date
    var lastSeen: Date
    var sightingCount: Int
    var latestRSSI: Int
    
    init(
        id: UUID,
        name: String,
        isTrusted: Bool = false,
        firstSeen: Date = .now,
        lastSeen: Date = .now,
        sightingCount: Int = 0,
        latestRSSI: Int = 0
    ) {
        self.id = id
        self.name = name
        self.isTrusted = isTrusted
        self.firstSeen = firstSeen
        self.lastSeen = lastSeen
        self.sightingCount = sightingCount
        self.latestRSSI = latestRSSI
    }
}
