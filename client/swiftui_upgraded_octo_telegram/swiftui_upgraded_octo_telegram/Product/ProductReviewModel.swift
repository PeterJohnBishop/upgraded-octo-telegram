//
//  ProductReviewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct ReviewModel: Identifiable, Codable {
    var id: String // Computed as uuidv4()
    var userId: String
    var productId: String
    var verified: Bool
    var rating: Int // Assuming a 1-5 star rating system
    var comment: String
}
