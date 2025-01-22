//
//  SelectProductView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by Peter Bishop on 1/19/25.
//

import SwiftUI

struct SelectProductView: View {
    @State private var productVM: ProductViewModel = ProductViewModel()
    @State private var productsFetched: Bool = false
    @State private var showAlert: Bool = false
    @State private var updating: Bool = false
    @Binding var orderVM: OrderViewModel
    var showCategory: MenuCategory.ID
    
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
                ForEach(productVM.products, id: \.id) { prod in
                    if showCategory == "all" {
                        HStack{
                            Button(action: {
                                // show sheet
                            }, label: {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.black)
                            }).padding()
                            VStack(alignment: .leading){
                                Text(prod.category).fontWeight(.ultraLight)
                                Text(prod.name).fontWeight(.heavy)
                                Text(String(format: "$%.2f", prod.price))
                            }
                            Spacer()
                            VStack{
                                if !updating {
                                    Text("\(orderVM.order.product.filter { $0.id == prod.id }.count)")
                                } else {
                                    Text("\(orderVM.order.product.filter { $0.id == prod.id }.count)")
                                }
                                HStack{
                                    Button(action: {
                                        updating = true
                                        let update = orderVM.removeProduct(prod)
                                        DispatchQueue.main.async {
                                            orderVM.order.product = update
                                            updating = false
                                        }
                                    }, label: {
                                        Image(systemName: "minus")
                                            .resizable()
                                            .frame(width: 25, height: 4)
                                            .foregroundStyle(.black)
                                    }).padding()
                                    Button(action: {
                                        updating = true
                                        DispatchQueue.main.async {
                                            orderVM.order.product.append(prod)
                                            updating = false
                                        }
                                    }, label: {
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .foregroundStyle(.black)
                                    }).padding()
                                }
                            }
                        }.padding()
                    } else {
                        if prod.category == showCategory {
                            HStack{
                                Button(action: {
                                    // show sheet
                                }, label: {
                                    Image(systemName: "info.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundStyle(.black)
                                })
                                VStack(alignment: .leading){
                                    Text(prod.category).fontWeight(.ultraLight)
                                    Text(prod.name).fontWeight(.heavy)
                                    Text(String(format: "$%.2f", prod.price))
                                }
                                Spacer()
                                VStack{
                                    if !updating {
                                        Text("\(orderVM.order.product.filter { $0.id == prod.id }.count)")
                                    } else {
                                        Text("\(orderVM.order.product.filter { $0.id == prod.id }.count)")
                                    }
                                    HStack{
                                        Button(action: {
                                            updating = true
                                            let update = orderVM.removeProduct(prod)
                                            DispatchQueue.main.async {
                                                orderVM.order.product = update
                                                updating = false
                                            }
                                        }, label: {
                                            Image(systemName: "minus")
                                                .resizable()
                                                .frame(width: 25, height: 4)
                                                .foregroundStyle(.black)
                                        }).padding()
                                        Button(action: {
                                            updating = true
                                            DispatchQueue.main.async {
                                                orderVM.order.product.append(prod)
                                                updating = false
                                            }
                                        }, label: {
                                            Image(systemName: "plus")
                                                .resizable()
                                                .frame(width: 25, height: 25)
                                                .foregroundStyle(.black)
                                        }).padding()
                                        
                                    }
                                }
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

struct SelectProductView_Preview: PreviewProvider {
    @State static var orderVM: OrderViewModel = OrderViewModel()

    static var previews: some View {
        SelectProductView(orderVM: $orderVM, showCategory: "all")
    }
}

