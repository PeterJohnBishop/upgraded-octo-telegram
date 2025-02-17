//
//  ProductViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/12/25.
//

import Foundation
import Observation
import SwiftUI

class ProductViewModel: Observable {
    var products: [ProductModel] = []
    var product: ProductModel = ProductModel(id: "", name: "", description: "", images: [], price: 0.00, category: "", featured: false)
    var errorMessage: String? = nil
    
    let baseURL = "http://localhost:8080/products"

    // Create a new product
    func createProduct(newProduct: ProductModel) async throws -> Bool {
        print("iOS: Sending Create Product Request")
        guard let url = URL(string: "\(baseURL)/product") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(newProduct)
        
        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        
        print("iOS: \(request)")
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("iOS: Product Created: 201 response")
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
    
    func fetchProductById(productId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/product/\(productId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseData = try JSONDecoder().decode(ProductModel.self, from: data)
        self.product = responseData
        return true
    }
    
    func fetchProducts() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        let responseData = try JSONDecoder().decode([ProductModel].self, from: data)
        self.products = responseData
        return true
    }
    
    func updateProduct(productId: String, updatedProduct: ProductModel) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/product/\(productId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(updatedProduct)

        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return true
    }
    
    func deleteProduct(productId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/product/\(productId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return true
    }
}
