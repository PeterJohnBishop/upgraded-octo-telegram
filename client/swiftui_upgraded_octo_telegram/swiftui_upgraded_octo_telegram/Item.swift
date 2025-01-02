//
//  Item.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/1/25.
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
