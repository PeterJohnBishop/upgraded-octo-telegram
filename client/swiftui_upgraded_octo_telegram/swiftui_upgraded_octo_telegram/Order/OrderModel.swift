//
//  OrderModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct OrderModel: Identifiable, Codable {
    var id: String // Computed as hashString(Date.now().toString())
    var userId: String
    var products: [String] // Product IDs
    var total: Double
    var address: String
}
