//
//  OrderMenuView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by Peter Bishop on 1/19/25.
//

import SwiftUI

struct OrderMenuView: View {
    @State private var productVM: ProductViewModel = ProductViewModel()
    @State private var appetizersSelected: Bool = false
    @State private var sidesSelected: Bool = false
    @State private var entreesSelected: Bool = false
    @State private var dessertsSelected: Bool = false
    @State private var naSelected: Bool = false
    @State private var beerSelected: Bool = false
    @State private var wineSelected: Bool = false
    @State private var spiritsSelected: Bool = false
    @State private var cocktailsSelected: Bool = false
    @Binding var orderVM: OrderViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView{
                    Text("Food")
                        .font(.system(size: 24))
                        .fontWeight(.ultraLight)
                        .padding()
                    // horizontal scrolling specials
                    Button("Appetizers", action: {
                        appetizersSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if appetizersSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Appetizer")
                    }
                    Button("Sides", action: {
                        sidesSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if sidesSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Side")
                    }
                    Button("Entrees", action: {
                        entreesSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if entreesSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Entree")
                    }
                    Button("Desserts", action: {
                        dessertsSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if dessertsSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Dessert")
                    }
                    Text("Drinks")
                        .font(.system(size: 24))
                        .fontWeight(.ultraLight)
                        .padding()
                    // horizontal scrolling specials
                    Button("Cocktails", action: {
                        cocktailsSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if cocktailsSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Cocktail")
                    }
                    Button("N/A Bevs", action: {
                        naSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if naSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "N/A Beverage")
                    }
                    Button("Beer", action: {
                        beerSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if beerSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Beer")
                    }
                    Button("Wine", action: {
                        wineSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if wineSelected {
                        SelectProductView(orderVM: $orderVM, showCategory: "Wine")
                    }
                    Button("Spirits", action: {
                        spiritsSelected.toggle()
                    })
                    .frame(width: 300)
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    ).padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    if spiritsSelected {
                        SelectProductView(orderVM: $orderVM,  showCategory: "Spirit")
                    }
            }
        }
    }
}

struct OrderMenuView_Preview: PreviewProvider {
    @State static var orderVM: OrderViewModel = OrderViewModel()

    static var previews: some View {
        OrderMenuView(orderVM: $orderVM)
    }
}
