//
//  UserWishlistModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct WishlistModel: Identifiable, Codable {
    var id: String // Computed as uuidv4()
    var userId: String
    var products: [String] // Product IDs
}

