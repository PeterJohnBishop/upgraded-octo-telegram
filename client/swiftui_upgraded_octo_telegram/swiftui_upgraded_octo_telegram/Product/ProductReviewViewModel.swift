//
//  ReviewReviewViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class ReviewViewModel: Observable {
    var reviews: [ReviewModel] = []
    var review: ReviewModel? = nil
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/reviews"

    func createReview(newReview: ReviewModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newReview)
        
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
                    self.fetchReviews()
                    completion(true)
                }
            }
        }.resume()
    }
    
    func fetchReviewById(id: String) {
        guard let url = URL(string: "\(baseURL)/review/\(id)") else { return }
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
                    self.review = try? JSONDecoder().decode(ReviewModel.self, from: data)
                }
            }
        }.resume()
    }

    func fetchReviews() {
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
                    self.reviews = (try? JSONDecoder().decode([ReviewModel].self, from: data)) ?? []
                }
            }
        }.resume()
    }

    func updateReview(id: String, updatedReview: ReviewModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review/\(id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedReview)
        
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
                    self.fetchReviews()
                    completion(true)
                }
            }
        }.resume()
    }

    func deleteReview(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/review/\(id)") else { return }
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
                    self.fetchReviews()
                    completion(true)
                }
            }
        }.resume()
    }
}

