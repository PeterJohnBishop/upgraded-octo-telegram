//
//  OrderHistoryViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class HistoryViewModel: Observable {
    var historys: [HistoryModel] = []
    var history: HistoryModel? = nil
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/products"

    func createHistory(newHistory: HistoryModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/history") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newHistory)
        
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
                    self.fetchHistorys()
                    completion(true)
                }
            }
        }.resume()
    }
    
    func fetchHistoryById(id: String) {
        guard let url = URL(string: "\(baseURL)/history/\(id)") else { return }
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
                    self.history = try? JSONDecoder().decode(HistoryModel.self, from: data)
                }
            }
        }.resume()
    }

    func fetchHistorys() {
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
                    self.historys = (try? JSONDecoder().decode([HistoryModel].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func updateHistory(id: String, updatedHistory: HistoryModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/history/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedHistory)
        
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
                    self.fetchHistorys()
                    completion(true)
                }
            }
        }.resume()
    }

    func deleteHistory(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/history/\(id)") else { return }
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
                    self.fetchHistorys()
                    completion(true)
                }
            }
        }.resume()
    }
}
