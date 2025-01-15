//
//  ListProductView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/14/25.
//

import SwiftUI

struct ListProductView: View {
    @State private var productVM: ProductViewModel = ProductViewModel()
    @State private var allProducts: [ProductModel] = []
    @State private var showAlert: Bool = false
    
    var body: some View {
        ScrollView {
            if allProducts.isEmpty {
                ProgressView()
                    .onAppear {
                        Task {
                            do {
                                allProducts = try await productVM.fetchProductss()
                            } catch {
                                DispatchQueue.main.async {
                                    showAlert = true
                                    productVM.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
            } else {
                ForEach(allProducts, id: \.id) { prod in
                    Text(prod.name)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(productVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ListProductView()
}
