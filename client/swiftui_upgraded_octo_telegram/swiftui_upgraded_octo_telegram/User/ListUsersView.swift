//
//  ListUsersView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/12/25.
//

import SwiftUI

struct ListUsersView: View {
    @State private var userVM: UserViewModel = UserViewModel()
    @State private var allUsers: [UserModel] = []
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            if allUsers.isEmpty {
                ProgressView()
                    .onAppear {
                        Task {
                            do {
                                allUsers = try await userVM.fetchUsers()
                            } catch {
                                DispatchQueue.main.async {
                                    showAlert = true
                                    userVM.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
            } else {
                ForEach(allUsers, id: \.id) { user in
                    Text(user.name)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(userVM.errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    ListUsersView()
}
