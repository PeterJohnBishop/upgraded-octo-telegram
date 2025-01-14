//
//  S3ViewModel.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/14/25.
//

import Foundation
import Observation
import UIKit

@Observable class S3ViewModel {
    var imageUrl: String = ""
    var imageUrls: [String] = []
    var isUploading: Bool = false
    var error: String = ""
    
    let baseURL = "http://localhost:8080/s3"
    
    func uploadImageToS3(image: UIImage) async -> Bool {
        guard let url = URL(string: "\(baseURL)/upload") else { return false }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return false }
        
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            self.error = "Error: No token found."
            print(self.error)
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return false
            }
            
            // Now 'data' is guaranteed to be non-optional
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let url = json["uploadURL"] as? String {
                print("Parsed JSON response:", json)
                self.imageUrl = url
                print(self.imageUrl)
                return true
            } else {
                print("Failed to parse JSON or 'imageUrl' not found.")
                return false
            }
        } catch {
            print("Error:", error)
            return false
        }
    }
    
    func uploadImagesToS3(images: [UIImage]) async -> Bool {
        isUploading = true
        defer { isUploading = false }
        
        for image in images {
            guard let url = URL(string: "\(baseURL)/upload-multiple") else {
                self.error = "Error: Invalid URL."
                return false
            }
            
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                self.error = "Error: Unable to compress image."
                return false
            }
            
            guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
                self.error = "Error: No token found."
                return false
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self.error = "HTTP Error: \(httpResponse.statusCode)"
                    print(self.error)
                    return false
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let fileUrls = json["fileUrls"] as? [String] {
                    self.imageUrls.append(contentsOf: fileUrls) // Append all file URLs to imageUrls
                } else {
                    self.error = "Failed to parse JSON or 'fileUrls' not found."
                    print(self.error)
                    return false
                }
            } catch {
                self.error = "Error: \(error.localizedDescription)"
                print(self.error)
                return false
            }
        }
        
        return true
    }


}
