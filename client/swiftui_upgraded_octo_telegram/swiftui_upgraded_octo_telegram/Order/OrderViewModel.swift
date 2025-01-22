//
//  OrderViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by Peter Bishop on 1/19/25.
//

import Foundation
import Observation
import SwiftUI

class OrderViewModel: Observable {
    var orders: [OrderModel] = []
    var order: OrderModel = OrderModel(id: "", user: "", timestamp: 0, product: [], total: 0.0, name: "", address: "", phone: "")
    var errorMessage: String? = nil
    
    let baseURL = "http://localhost:8080/orders"
    
    func removeProduct(_ product: ProductModel) -> [ProductModel] {
        if let index = order.product.firstIndex(where: { $0.id == product.id }) {
            order.product.remove(at: index)
        }
        return order.product
    }
    
    func createOrder(newOrder: OrderModel) async throws -> Bool {
        print("iOS: Sending Create Order Request")
        guard let url = URL(string: "\(baseURL)/order") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(newOrder)
        
        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        print("iOS: \(request)")
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("iOS: Order Created: 201 response")
                return true
            } else {
                print("iOS: 500 Error!")
                throw URLError(.badServerResponse)
            }
        } catch {
            self.errorMessage = error.localizedDescription
            print(self.errorMessage ?? "Error: UNKNOWN")
            throw error
        }
    }
}
