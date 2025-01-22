//
//  SignUpView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/10/25.
//

import SwiftUI

struct SignUpView: View {
    @State var userVM: UserViewModel = UserViewModel()
    @State var confirmPassword: String = ""
    @State var existingUser: Bool = false
    @State var showAlert: Bool = false
    @State var userCreated: Bool = false
    
    
    var body: some View {
        NavigationStack{
            VStack{
                Spacer()
                Text("SignUp").font(.system(size: 34))
                    .fontWeight(.ultraLight)
                Divider().padding()
                TextField("Name", text: $userVM.user.name)
                    .tint(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
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
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .tint(.black)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .textContentType(.oneTimeCode)
                
                Button("Submit", action: {
                    if confirmPassword == userVM.user.password {
                        Task {
                            do {
                                let created = try await userVM.createUser()
                                    userCreated = created
                            } catch {
                                userVM.errorMessage = "An error occurred: \(error.localizedDescription)"
                            }
                        }
                    } else {
                        userVM.errorMessage = "Passwords must match!"
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
                .navigationDestination(isPresented: $userCreated, destination: {
                    ConfirmationView().navigationBarBackButtonHidden(true)
                })
                Spacer()
                HStack{
                    Spacer()
                    Text("I have an account.").fontWeight(.ultraLight)
                    Button("Login", action: {
                        existingUser = true
                    }).foregroundStyle(.black)
                        .fontWeight(.light)
                        .navigationDestination(isPresented: $existingUser, destination: {
                            LoginView().navigationBarBackButtonHidden(true)
                        })
                    Spacer()
                }
            }.onAppear{
                
            }
        }
    }
}


#Preview {
    SignUpView()
}
