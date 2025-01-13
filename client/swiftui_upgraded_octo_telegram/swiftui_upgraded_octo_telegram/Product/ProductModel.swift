//
//  ProductModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/12/25.
//

import Foundation

enum MenuCategory: String, CaseIterable {
    case appetizer = "appetizer"
    case side = "side"
    case entree = "entree"
    case desserts = "dessert"
    case naBeverages = "naBeverage"
    case beer = "beer"
    case wine = "wine"
    case spirits = "spirit"
    case cocktails = "coctail"

    var displayName: String {
        return self.rawValue
    }
}

struct ProductModel: Identifiable, Codable {
    var id: String // Computed as `p_${hashString(name)}`
    var description: String
    var image: String
    var price: Double
    var category: String
    var featured: Bool
}
