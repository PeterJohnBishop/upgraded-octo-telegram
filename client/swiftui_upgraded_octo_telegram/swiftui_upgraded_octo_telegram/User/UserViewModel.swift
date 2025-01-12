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
    var user: UserModel = UserModel(id: 0, name: "", email: "", password: "")  
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
    func createUser(newUser: UserModel) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/user") else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(newUser)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                return true
            } else {
                throw URLError(.badServerResponse)
            }
        } catch {
            // Handle and propagate errors
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            throw error
        }
    }
    
    // Authenticate user
    func authenticateUser(email: String, password: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/auth") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 200 {
            let responseData = try JSONDecoder().decode(AuthResponse.self, from: data)
            UserDefaults.standard.set(responseData.jwt, forKey: "jwtToken")
            self.user = responseData.user
            return true
        } else {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message])
        }
    }
    
    // Read one user by ID
    func fetchUserById(userId: String) async throws -> UserModel {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        guard let jwt = UserDefaults.standard.string(forKey: "jwtToken") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "JWT not available"])
        }

        request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(UserModel.self, from: data)
    }
    
    // Read all users
    func fetchUsers() async throws -> [UserModel] {
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
        return try JSONDecoder().decode([UserModel].self, from: data)
    }
    
    // Update a user
    func updateUser(userId: String, updatedUser: UserModel) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(updatedUser)

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

    // Delete a user
    func deleteUser(userId: String) async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/user/\(userId)") else {
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
