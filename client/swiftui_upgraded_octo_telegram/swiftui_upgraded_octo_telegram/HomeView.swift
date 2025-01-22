//
//  HomeView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/10/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var currentUser: UserModel
    @State var token: String = ""
    @State var selection: Int = 2
    @State var logout: Bool = false
    @State var addProduct: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                showSelection(selected: $selection, currentUser: $currentUser)
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        selection = 0
                    }, label: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.black)
                    })
                    Spacer()
                    Button(action: {
                        selection = 1
                    }, label: {
                        Image(systemName: "list.bullet.circle.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(.black)
                    })
                    Spacer()
                    Button(action: {
                        selection = 2
                    }, label: {
                        Image(systemName: "rectangle.stack.fill")
                            .resizable()
                            .frame(width: 80, height: 75)
                            .foregroundStyle(.black)
                    })
                    Spacer()
                    Button(action: {
                        selection = 3
                    }, label: {
                        Image(systemName: "message.circle.fill")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundStyle(.black)
                    })
                    Spacer()
                    Button(action: {
                        selection = 4
                    }, label: {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(.black)
                    })
                    Spacer()
                }
            }.padding()
                .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
            .onAppear{
                token = UserDefaults.standard.string(forKey: "jwtToken") ?? "Token Not Found"
                SocketService.shared.socket.emit("verifyToken", ["token": token])
            }
        }
    }
}

struct showSelection: View {
    @Binding var selected: Int
    @Binding var currentUser: UserModel
    
    var body: some View {
        if selected == 0 {
            UserAccountView()
        }
        if selected == 1 {
            ListMenuView(currentUser: $currentUser).ignoresSafeArea()
        }
        if selected == 2 {
            CreateOrderView()
        }
        if selected == 3 {
            MessageFeedView()
        }
        if selected == 4 {
            CheckoutView()
        }
    }
}

struct Home_Previews: PreviewProvider {
    @State static var sampleUser = UserModel(id: "99999999", name: "Mike Ellingsworth", email: "m.ellingsworth@gmail.com", password: "123456789ABC")

    static var previews: some View {
        HomeView(currentUser: $sampleUser)
    }
}
