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
    var lastSeen: Date
    var latestRSSI: Int
    
    init(
        id: UUID,
        name: String,
        isTrusted: Bool = false,
        lastSeen: Date = .now,
        latestRSSI: Int = 0
    ) {
        self.id = id
        self.name = name
        self.isTrusted = isTrusted
        self.lastSeen = lastSeen
        self.latestRSSI = latestRSSI
    }
}
