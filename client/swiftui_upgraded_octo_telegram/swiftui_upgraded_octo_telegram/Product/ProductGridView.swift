//
//  ProductGridView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/15/25.
//

import Foundation
import SwiftUI

struct ProductGridView: View {
    @State private var productVM: ProductViewModel = ProductViewModel()
    @State private var productsFetched: Bool = false
    @State private var showAlert: Bool = false
    var showCategory: MenuCategory.ID
    
    // Define grid layout
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            if !productsFetched {
                ProgressView()
                    .onAppear {
                        Task {
                            do {
                                let success = try await productVM.fetchProducts()
                                DispatchQueue.main.async {
                                    productsFetched = success
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    showAlert = true
                                    productVM.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(productVM.products, id: \.id) { prod in
                        if showCategory == "all" {
                            ZStack {
                                // Display the product image
                                AsyncAwaitImageView(imageUrl: URL(string: prod.images[0])!)
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                // Overlay the product name
                                VStack{
                                    Spacer()
                                    Text(prod.name)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Capsule())
                                        .padding(6)
                                        .frame(maxWidth: 150) // Ensure overlay fits within the card
                                        .multilineTextAlignment(.center)
                                }
                            }
                        } else {
                            if prod.category == showCategory {
                                ZStack {
                                    // Display the product image
                                    AsyncAwaitImageView(imageUrl: URL(string: prod.images[0])!)
                                        .frame(width: 150, height: 150)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                    
                                    // Overlay the product name
                                    VStack{
                                        Spacer()
                                        Text(prod.name)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Capsule())
                                            .padding(6)
                                            .frame(maxWidth: 150) // Ensure overlay fits within the card
                                            .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(productVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
}

#Preview {
    ProductGridView(showCategory: "all")
}
