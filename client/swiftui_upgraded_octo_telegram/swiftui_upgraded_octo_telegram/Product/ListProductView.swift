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
    var showCategory: MenuCategory.ID
    
    var body: some View {
        ScrollView {
            if allProducts.isEmpty {
                Text("No \(showCategory)s today")
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
                    if showCategory == "all" {
                        HStack{
                            AsyncAwaitImageView(imageUrl: URL(string: prod.images[0])!)
                                .frame(width: 125, height: 125)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            VStack(alignment: .leading){
                                Text(prod.category).fontWeight(.ultraLight)
                                Text(prod.name).fontWeight(.heavy)
                                Text(String(format: "$%.2f", prod.price))
                                Text(prod.description).fontWeight(.light)
                            }
                            Spacer()
                        }.padding()
                    } else {
                        if prod.category == showCategory {
                            HStack{
                                AsyncAwaitImageView(imageUrl: URL(string: prod.images[0])!)
                                    .frame(width: 125, height: 125)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                                VStack(alignment: .leading){
                                    Text(prod.category).fontWeight(.ultraLight)
                                    Text(prod.name).fontWeight(.heavy)
                                    Text(String(format: "$%.2f", prod.price))
                                    Text(prod.description).fontWeight(.light)
                                }
                                Spacer()
                            }.padding()
                        }
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(productVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ListProductView(showCategory: "all")
}
