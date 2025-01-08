//
//  UserWishlistViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class WishlistViewModel: Observable {
    var wishlists: [WishlistModel] = []
    var wishlist: WishlistModel? = nil
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/wishlists"

    func createWishlist(newWishlist: WishlistModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newWishlist)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchWishlists()
                    completion(true)
                }
            }
        }.resume()
    }

    func fetchWishlists() {
        guard let url = URL(string: baseURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.wishlists = (try? JSONDecoder().decode([WishlistModel].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func fetchWishlistById(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.wishlist = try? JSONDecoder().decode(WishlistModel.self, from: data)
                }
            }
        }.resume()
    }

    func updateWishlist(id: String, updatedWishlist: WishlistModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedWishlist)

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchWishlists()
                    completion(true)
                }
            }
        }.resume()
    }

    func deleteWishlist(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchWishlists()
                    completion(true)
                }
            }
        }.resume()
    }
}
