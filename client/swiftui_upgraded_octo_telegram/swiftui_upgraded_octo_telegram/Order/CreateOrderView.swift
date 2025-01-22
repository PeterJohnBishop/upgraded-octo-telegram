//
//  CreateOrderView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/16/25.
//

import SwiftUI

struct CreateOrderView: View {
    @State private var orderVM: OrderViewModel = OrderViewModel()
    @State private var showMenu: Bool = false
    @State private var updating: Bool = false
    
    var body: some View {
        ScrollView{
            Text("Orders")
                .font(.system(size: 34))
                .fontWeight(.ultraLight)
            Divider().padding()
            if !updating {
                GroupBox("New Order", content: {
                    VStack{
                        ForEach(orderVM.order.product) { prod in
                            HStack{
                                Text(prod.name)
                                Spacer()
                                Text(String(prod.price))
                            }
                        }
                        HStack{
                            Button(action: {
                                showMenu = true
                            }, label: {
                                Image(systemName: "plus")
                            })
                            .fontWeight(.ultraLight)
                            .foregroundColor(.black)
                            .padding()
                            .sheet(isPresented: $showMenu, onDismiss: {
                                updating.toggle()
                                updating.toggle()
                            }, content: {
                                OrderMenuView(orderVM: $orderVM).padding()
                                    .ignoresSafeArea()
                            })
                            Spacer()
                            if !orderVM.order.product.isEmpty {
                                Button(action: {
                                    //                                showMenu = true
                                }, label: {
                                    Image(systemName: "chevron.right")
                                })
                                .fontWeight(.ultraLight)
                                .foregroundColor(.black)
                                .padding()
                                .sheet(isPresented: $showMenu, onDismiss: {
                                    updating.toggle()
                                    updating.toggle()
                                }, content: {
                                    OrderMenuView(orderVM: $orderVM).padding()
                                        .ignoresSafeArea()
                                })
                            }
                        }
                    }
                }).padding()
            }
        }
    }
}

#Preview {
    CreateOrderView()
}
