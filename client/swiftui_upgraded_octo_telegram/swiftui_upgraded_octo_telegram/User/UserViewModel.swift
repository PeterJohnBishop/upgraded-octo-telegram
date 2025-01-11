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
    
    struct AuthResponse: Codable {
        let message: String
        let user: UserModel
        let jwt: String
    }
    
    struct TokenResponse: Decodable {
        let accessToken: String
    }
    
    struct ErrorResponse: Codable {
        let message: String
    }

    let baseURL = "http://localhost:8080/users" // Replace with your backend URL

    // Create a new user
    func createUser(newUser: UserModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/user") else { return }
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
    
    // Authenticate user
    func authenticateUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received."
                    completion(false)
                    return
                }

                do {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        let responseData = try JSONDecoder().decode(AuthResponse.self, from: data)
                        UserDefaults.standard.set(responseData.jwt, forKey: "jwtToken")
                        self.user = responseData.user
                        completion(true)
                    } else {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        self.errorMessage = errorResponse.message
                        completion(false)
                    }
                } catch {
                    self.errorMessage = "Failed to decode response."
                    completion(false)
                }
            }
        }.resume()
    }
    
    // Read one user by ID
    func fetchUserById(userId: String) {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else { return }
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

    // Read all users
    func fetchUsers() {
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

    // Update a user
    func updateUser(userId: String, updatedUser: UserModel, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updatedUser)
        
        if let jwt = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "JWT not available"
            }
            return
        }

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
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else { return }
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
