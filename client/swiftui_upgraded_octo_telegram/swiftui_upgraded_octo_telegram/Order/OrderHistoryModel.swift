//
//  OrderHistoryModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct HistoryModel: Identifiable, Codable {
    var id: String // Computed as uuidv4()
    var userId: String
    var products: [String] // Product IDs
    var total: Double
    var address: String
    var status: String
}
