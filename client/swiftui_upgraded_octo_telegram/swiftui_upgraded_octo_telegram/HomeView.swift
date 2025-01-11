//
//  HomeView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/10/25.
//

import SwiftUI

struct HomeView: View {
    @State var token: String = ""
    
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }.onAppear{
            token = UserDefaults.standard.string(forKey: "jwtToken") ?? "Token Not Found"
            SocketService.shared.socket.emit("verifyToken", ["token": token])
        }
    }
}

#Preview {
    HomeView()
}
