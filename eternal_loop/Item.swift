//
//  Item.swift
//  eternal_loop
//
//  Created by firstfu on 2026/1/30.
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
