//
//  LoginView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/10/25.
//

import SwiftUI

struct LoginView: View {
    @State var userVM: UserViewModel = UserViewModel()
    @State var confirmPassword: String = ""
    @State var existingUser: Bool = false
    @State var showAlert: Bool = false
    @State var userAuthenticated: Bool = false
    @State var socketConnected: Bool = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                Text("Login").font(.system(size: 34))
                    .fontWeight(.ultraLight)
                Divider().padding()
                TextField("Email", text: $userVM.user.email)
                    .tint(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                SecureField("Password", text: $userVM.user.password)
                    .tint(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .textContentType(.oneTimeCode)
                if SocketService.shared.connected {
                    Button("Submit", action: {
                        Task{
                            do {
                                let authenticated = try await userVM.authenticateUser()
                                DispatchQueue.main.async {
                                    userAuthenticated = authenticated
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    showAlert = true
                                    userVM.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    })
                    .fontWeight(.ultraLight)
                    .foregroundColor(.black)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .gray.opacity(0.4), radius: 4, x: 2, y: 2)
                    )
                    .onChange(of: userVM.errorMessage, {
                        oldResponse, newResponse in
                        if newResponse != nil {
                            showAlert = true
                        }
                    })
                    .alert("Error", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {
                            userVM.user.email = ""
                            userVM.user.password = ""
                            confirmPassword = ""
                            userVM.errorMessage = nil
                        }
                    } message: {
                        Text(userVM.errorMessage ?? "")
                    }
                    .navigationDestination(isPresented: $userAuthenticated, destination: {
                        HomeView(currentUser: $userVM.user).navigationBarBackButtonHidden(true)
                    })
                }
                Spacer()
                HStack{
                    Spacer()
                    Text("I don't have an account.").fontWeight(.ultraLight)
                    Button("SignUp", action: {
                        existingUser = true
                    }).foregroundStyle(.black)
                        .fontWeight(.light)
                        .navigationDestination(isPresented: $existingUser, destination: {
                            SignUpView().navigationBarBackButtonHidden(true)
                        })
                    Spacer()
                }
            }.onAppear{
                SocketService.shared.socket.connect()
            }
        }
    }
}

#Preview {
    LoginView()
}
