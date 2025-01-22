//
//  UserAccountView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/16/25.
//

import SwiftUI

struct UserAccountView: View {
    @State private var logout: Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("Hello, You!")
                Button(action: {
                    UserDefaults.standard.removeObject(forKey: "jwtToken")
                    logout = true
                }, label: {
                    Text("Logout")
                }).fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    )
                    .navigationDestination(isPresented: $logout, destination: {
                        LoginView().navigationBarBackButtonHidden(true)
                    })
                ListUsersView()
            }
        }
    }
}

#Preview {
    UserAccountView()
}
