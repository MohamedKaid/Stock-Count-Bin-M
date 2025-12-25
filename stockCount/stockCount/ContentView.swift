//
//  ContentView.swift
//  stockCount
//
//  Created by Mohamed Kaid on 11/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            HomeView()
        }
//        TabView {
//            NavigationStack {
//                HomeView()
//            }
//            .tabItem {
//                Label("Home", systemImage: "house")
//            }
//
//            NavigationStack {
//                Text("Create")
//            }
//            .tabItem {
//                Label("Create", systemImage: "sparkles")
//            }
//
//            NavigationStack {
//                Text("Settings")
//            }
//            .tabItem {
//                Label("Settings", systemImage: "gearshape")
//            }
//        }
    }
}

#Preview {
    ContentView()
        .environmentObject(InventoryStore())
        .environmentObject(CategoryStore())
}




