//
//  FeaturedHScrollView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by Peter Bishop on 1/20/25.
//

import SwiftUI

struct FeaturedHScrollView: View {
    @Binding var featuredProducts: [ProductModel]
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Loop through the indices of filtered products to provide bindings
                    ForEach(filteredProductIndices(), id: \.self) { index in
                        SingleProductView(prod: $featuredProducts[index])
                    }
                }
                .padding(.horizontal, 16)
                .onAppear {
                    setupInfiniteScroll()
                }
            }
        }
    }
    
    // Get indices of featured products
    private func filteredProductIndices() -> [Int] {
        featuredProducts.indices.filter { featuredProducts[$0].featured }
    }
    
    // Infinite scroll logic
    private func setupInfiniteScroll() {
        guard !featuredProducts.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Duplicate the featured products to create an infinite loop effect
            featuredProducts += featuredProducts.filter { $0.featured }
        }
    }
}

struct FeaturedHScrollView_Preview: PreviewProvider {
    @State static var sampleProducts = [
        ProductModel(id: "o_001F", name: "The Holiday", description: "A special cocktail", images: ["https://images.immediate.co.uk/production/volatile/sites/30/2022/06/Tequila-sunrise-fb8b3ab.jpg?quality=90&resize=556,505"], price: 30.00, category: MenuCategory.cocktails.id, featured: true),
        ProductModel(id: "o_002F", name: "The Trap", description: "A special cocktail", images: ["https://www.artofdrink.com/wp-content/uploads/2010/08/blue-lagoon-cocktail.jpg"], price: 30.00, category: MenuCategory.cocktails.id, featured: true),
        ProductModel(id: "o_003F", name: "The Murder", description: "A special cocktail", images: ["https://sweetpotatosoul.com/wp-content/uploads/2024/04/Strawberry-Bramble-Cocktails.jpeg"], price: 30.00, category: MenuCategory.cocktails.id, featured: true),
    ]

    static var previews: some View {
        FeaturedHScrollView(featuredProducts: $sampleProducts)
    }
}
