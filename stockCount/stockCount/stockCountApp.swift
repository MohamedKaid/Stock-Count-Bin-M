//
//  stockCountApp.swift
//  stockCount
//
//  Created by Mohamed Kaid on 11/13/25.
//


import SwiftUI
import FirebaseCore

@main
struct stockCountApp: App {

    @StateObject private var store = InventoryStore()
    @StateObject private var categoryStore = CategoryStore()   // ✅ add

    init() {
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if isPreview { return }

        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(categoryStore)
                
        }
    }
}
