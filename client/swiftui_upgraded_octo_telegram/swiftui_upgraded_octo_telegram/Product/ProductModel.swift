//
//  ProductModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/12/25.
//

import Foundation

enum MenuCategory: String, CaseIterable, Identifiable {
    case appetizer = "Appetizer"
    case side = "Side"
    case entree = "Entree"
    case desserts = "Dessert"
    case naBeverages = "N/A Beverage"
    case beer = "Beer"
    case wine = "Wine"
    case spirits = "Spirit"
    case cocktails = "Cocktail"
    case all = "all"
    
    var id: String { self.rawValue }

}

struct ProductModel: Identifiable, Codable {
    var id: String // Computed as `p_${hashString(name)}`
    var name: String
    var description: String
    var images: [String]
    var price: Double
    var category: String
    var featured: Bool
}
