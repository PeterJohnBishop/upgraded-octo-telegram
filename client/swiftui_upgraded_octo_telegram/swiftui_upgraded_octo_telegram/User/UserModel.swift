//
//  UserModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation

struct UserModel: Identifiable, Codable {
    var id: String // Computed as hashString(email)
    var name: String
    var email: String
    var password: String // Computed as bcrypt.hash(password, 10)
}
