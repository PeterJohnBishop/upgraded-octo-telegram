//
//  OrderViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class OrderViewModel: Observable {
    var orders: [OrderModel] = []
    var order: OrderModel? = nil
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/products"

    func createOrder(newOrder: OrderModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newOrder)

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchOrders()
                    completion(true)
                }
            }
        }.resume()
    }

    func fetchOrders() {
        guard let url = URL(string: baseURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.orders = (try? JSONDecoder().decode([OrderModel].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func fetchOrderById(id: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.order = try? JSONDecoder().decode(OrderModel.self, from: data)
                }
            }
        }.resume()
    }

    func updateOrder(id: String, updatedOrder: OrderModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedOrder)

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchOrders()
                    completion(true)
                }
            }
        }.resume()
    }

    func deleteOrder(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchOrders()
                    completion(true)
                }
            }
        }.resume()
    }
}
