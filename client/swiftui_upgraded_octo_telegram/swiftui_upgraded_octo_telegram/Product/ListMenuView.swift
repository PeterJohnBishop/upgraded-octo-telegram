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
    @State private var addProduct: Bool = false
    @State private var productsFetched: Bool = false
    @State private var showAlert: Bool = false
    @Binding var currentUser: UserModel
    
    var body: some View {
        NavigationStack{
            ScrollView{
                Text("Todays Menu")
                    .font(.system(size: 34))
                        .fontWeight(.ultraLight)
                Divider().padding()
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
                    Text("The Specials")
                        .font(.system(size: 24))
                            .fontWeight(.ultraLight)
                    FeaturedHScrollView(featuredProducts: $productVM.products)
                }
                Divider().padding()
                Text("The Food")
                    .font(.system(size: 24))
                        .fontWeight(.ultraLight)
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
                    ListProductView(showCategory: "Appetizer")
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
                    ListProductView(showCategory: "Side")
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
                    ListProductView(showCategory: "Entree")
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
                    ListProductView(showCategory: "Cocktail")
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
                    ListProductView(showCategory: "N/A Beverage")
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
                    ListProductView(showCategory: "Beer")
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
                    ListProductView(showCategory: "Wine")
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
                    ListProductView(showCategory: "Spirit")
                }
                Button(action: {
                    addProduct = true
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.black)
                }).padding()
                    .navigationDestination(isPresented: $addProduct, destination: {
                        CreateProductView(currentUser: $currentUser).navigationBarBackButtonHidden(true)
                    })
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(productVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

//#Preview {
//    ListMenuView()
//}

struct ListMenuView_Previews: PreviewProvider {
    @State static var sampleUser = UserModel(id: "99999999", name: "Mike Ellingsworth", email: "m.ellingsworth@gmail.com", password: "123456789ABC")

    static var previews: some View {
        HomeView(currentUser: $sampleUser)
    }
}

