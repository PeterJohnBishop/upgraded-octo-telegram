//
//  UserViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/7/25.
//

import Foundation
import Observation
import SwiftUI

class UserViewModel: Observable {
    var users: [UserModel] = [] // List of all users
    var user: UserModel? = nil  // A single user, fetched by ID
    var errorMessage: String? = nil

    let baseURL = "https://your-backend-url.com/api/users" // Replace with your backend URL

    // Create a new user
    func createUser(newUser: UserModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newUser)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                self.fetchUsers() // Refresh the list of users
                completion(true)
            }
        }.resume()
    }

    // Read all users
    func fetchUsers() {
        guard let url = URL(string: baseURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([UserModel].self, from: data)
                    DispatchQueue.main.async {
                        self.users = users
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode users"
                    }
                }
            }
        }.resume()
    }

    // Read one user by ID
    func fetchUserById(userId: String) {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(UserModel.self, from: data)
                    DispatchQueue.main.async {
                        self.user = user
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Failed to decode user"
                    }
                }
            }
        }.resume()
    }

    // Update a user
    func updateUser(userId: String, updatedUser: UserModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedUser)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                self.fetchUsers() // Refresh the list of users
                completion(true)
            }
        }.resume()
    }

    // Delete a user
    func deleteUser(userId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            DispatchQueue.main.async {
                self.fetchUsers() // Refresh the list of users
                completion(true)
            }
        }.resume()
    }
}
