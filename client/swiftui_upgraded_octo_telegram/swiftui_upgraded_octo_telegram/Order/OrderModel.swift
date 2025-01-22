//
//  OrderModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by Peter Bishop on 1/19/25.
//

import Foundation

struct OrderModel: Identifiable, Codable {
    var id: String // Computed as `0_${user.id}_${timestamp}`
    var user: String // user.id
    var timestamp: Int // Date.now() unix millisecond timestamp
    var product: [ProductModel]
    var total: Double
    var name: String
    var address: String
    var phone: String
}
