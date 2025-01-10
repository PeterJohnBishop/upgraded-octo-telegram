//
//  ContentView.swift
//  swiftui_upgraded_octo_telegram
//
//  Created by m1_air on 1/1/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        VStack{
            Text("Hello World")
        }.onAppear()
    }
    
    private func onAppear() {
        SocketService.shared.socket.connect()
    }
}

#Preview {
    ContentView()
}
