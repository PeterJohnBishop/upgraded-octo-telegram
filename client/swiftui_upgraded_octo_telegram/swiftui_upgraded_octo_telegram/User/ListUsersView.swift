//
//  ListUsersView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/12/25.
//

import SwiftUI

struct ListUsersView: View {
    @State private var userVM: UserViewModel = UserViewModel()
    @State private var usersFetched: Bool = false
    @State private var showAlert: Bool = false
    let currentUserId = UserDefaults.standard.string(forKey: "user_id")
    
    var body: some View {
        ScrollView {
            if !usersFetched {
                ProgressView()
                    .onAppear {
                        Task {
                            do {
                                let success = try await userVM.fetchUsers()
                                DispatchQueue.main.async {
                                    usersFetched = success
                                }
                            } catch {
                                DispatchQueue.main.async {
                                    showAlert = true
                                    userVM.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    }
            } else {
                ForEach(userVM.users, id: \.id) { user in
                    if user.id != currentUserId {
                        Text(user.name)
                    }
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
