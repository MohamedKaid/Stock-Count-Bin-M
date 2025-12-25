//
//  ExportInventoryButton.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import SwiftUI

struct ExportInventoryButton: View {
    @EnvironmentObject private var store: InventoryStore
    @EnvironmentObject private var categoryStore: CategoryStore
    
    @State private var exportURL: URL? = nil
    @State private var showExportError = false
    
    var body: some View {
        Group {
            if let exportURL {
                ShareLink(item: exportURL) {
                    Label("", systemImage: "square.and.arrow.up.fill")
                        .font(.system(size:20))
                        .foregroundStyle(Color(.white))
                }
            } else {
                Button {
                    do {
                        exportURL = try InventoryExport.makeCSVFile(
                            items: store.items,
                            categories: categoryStore.categories
                        )
                    } catch {
                        showExportError = true
                    }
                } label: {
                    Label("", systemImage: "square.and.arrow.down.fill")
                        .font(.system(size:20))
                        .foregroundStyle(Color(.white))
                        
                }
            }
        }
        .alert("Export failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Couldn’t create the export file. Try again.")
        }
    }
}
