//
//  ProductViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class ProductViewModel: Observable {
    var products: [ProductModel] = []
    var product: ProductModel? = nil
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/products"

    func createProduct(newProduct: ProductModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/product") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newProduct)
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchProducts()
                    completion(true)
                }
            }
        }.resume()
    }
    
    func fetchProductById(id: String) {
        guard let url = URL(string: "\(baseURL)/product/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.product = try? JSONDecoder().decode(ProductModel.self, from: data)
                }
            }
        }.resume()
    }

    func fetchProducts() {
        guard let url = URL(string: "\(baseURL)/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    self.products = (try? JSONDecoder().decode([ProductModel].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func updateProduct(id: String, updatedProduct: ProductModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/product/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedProduct)
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchProducts()
                    completion(true)
                }
            }
        }.resume()
    }

    func deleteProduct(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/product/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                } else {
                    self.fetchProducts()
                    completion(true)
                }
            }
        }.resume()
    }
}
