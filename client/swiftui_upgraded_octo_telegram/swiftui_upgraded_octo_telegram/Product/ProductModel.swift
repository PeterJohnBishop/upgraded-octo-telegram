//
//  ProductModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct ProductModel: Identifiable, Codable {
    var id: String // Computed as hashString(name)
    var name: String
    var description: String
    var price: Double
    var quantity: Int
    var imageURL: String
    var inventory: String
}
