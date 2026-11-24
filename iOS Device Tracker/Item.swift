//
//  Item.swift
//  iOS Device Tracker
//
//  Created by patron on 11/24/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
