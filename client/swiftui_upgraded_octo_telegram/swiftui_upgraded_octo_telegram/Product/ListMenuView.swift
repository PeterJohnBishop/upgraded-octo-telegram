//
//  ListMenuView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/16/25.
//

import SwiftUI

struct ListMenuView: View {
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
    
    //case appetizer = "Appetizer"
    //case side = "Side"
    //case entree = "Entree"
    //case desserts = "Dessert"
    //case naBeverages = "N/A Beverage"
    //case beer = "Beer"
    //case wine = "Wine"
    //case spirits = "Spirit"
    //case cocktails = "Cocktail"
    //case all = "all"
    
    var body: some View {
        NavigationStack{
            ScrollView{
                Text("Todays Menu")
                    .font(.system(size: 34))
                        .fontWeight(.ultraLight)
                Divider().padding()
                Text("The Food")
                    .font(.system(size: 24))
                        .fontWeight(.ultraLight)
                // horizontal scrolling specials
                Button("Appetizers", action: {
                    appetizersSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if appetizersSelected {
                    ListProductView(showCategory: "Appetizer")
                }
                Button("Sides", action: {
                    sidesSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if sidesSelected {
                    ListProductView(showCategory: "Side")
                }
                Button("Entrees", action: {
                    entreesSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if entreesSelected {
                    ListProductView(showCategory: "Entree")
                }
                Button("Desserts", action: {
                    dessertsSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if dessertsSelected {
                    ListProductView(showCategory: "Dessert")
                }
                Divider().padding()
                Text("The Drinks")
                    .font(.system(size: 24))
                        .fontWeight(.ultraLight)
                // horizontal scrolling specials
                Button("Cocktails", action: {
                    cocktailsSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if cocktailsSelected {
                    ListProductView(showCategory: "Cocktail")
                }
                Button("N/A Bevs", action: {
                    naSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if naSelected {
                    ListProductView(showCategory: "N/A Beverage")
                }
                Button("Beer", action: {
                    beerSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if beerSelected {
                    ListProductView(showCategory: "Beer")
                }
                Button("Wine", action: {
                    wineSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if wineSelected {
                    ListProductView(showCategory: "Wine")
                }
                Button("Spirits", action: {
                    spiritsSelected.toggle()
                })
                .frame(width: 350)
                .fontWeight(.ultraLight)
                .foregroundColor(.black)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                )
                if spiritsSelected {
                    ListProductView(showCategory: "Spirit")
                }
            }
        }
    }
}

#Preview {
    ListMenuView()
}
