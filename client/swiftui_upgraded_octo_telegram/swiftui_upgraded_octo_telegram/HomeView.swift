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
    
    var body: some View {
        VStack{
            Text("Hello, \(currentUser.name)")
            // featured products
            // product category grid
            // orders
        }.onAppear{
            token = UserDefaults.standard.string(forKey: "jwtToken") ?? "Token Not Found"
            SocketService.shared.socket.emit("verifyToken", ["token": token])
        }
    }
}

//#Preview {
//    HomeView()
//}
