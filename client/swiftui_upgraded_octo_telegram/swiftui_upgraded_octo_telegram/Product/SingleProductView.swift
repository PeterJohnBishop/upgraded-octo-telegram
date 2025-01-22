//
//  SingleProductView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/15/25.
//

import SwiftUI

struct SingleProductView: View {
    @Binding var prod: ProductModel
    
    var body: some View {
        GroupBox(content: {
            VStack{
                HStack{
                    VStack{
                        HStack{
                            Text(prod.category).fontWeight(.ultraLight)
                            Spacer()
                        }
                        HStack{
                            Text(prod.name).fontWeight(.light)
                            Text(String(format: "$%.2f", prod.price))
                            Spacer()
                        }
                    }
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(prod.images.indices, id: \.self) { index in
                            let image = prod.images[index]
                            AsyncAwaitImageView(imageUrl: URL(string: image)!)
                                .frame(width: 250, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                    }.padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                }
                VStack(alignment: .leading){
                    Text(prod.description).fontWeight(.light)
                }.padding()
            }
        }).padding()
    }
}

struct SingleProductView_Previews: PreviewProvider {
    @State static var sampleProduct = ProductModel(
        id: "1",
        name: "Sample Product",
        description: "This is a sample product description.",
        images: ["https://upgradedoctotelegram.s3.amazonaws.com/uploads/1736894784492_image.jpg",
                  "https://upgradedoctotelegram.s3.amazonaws.com/uploads/1736894785627_image.jpg",
                  "https://upgradedoctotelegram.s3.amazonaws.com/uploads/1736894785936_image.jpg"],
        price: 29.99,
        category: MenuCategory.entree.id,
        featured: false
    )

    static var previews: some View {
        SingleProductView(prod: $sampleProduct)
    }
}
