//
//  ExportInventoryButton.swift
//  stockCount
//

import SwiftUI

struct ExportInventoryButton: View {
    @EnvironmentObject private var store: InventoryStore
    @EnvironmentObject private var categoryStore: CategoryStore

    @State private var showExportError = false
    @State private var shareURL: URL? = nil

    var body: some View {
        Button {
            do {
                shareURL = try InventoryExport.makeXLSXFile(
                    items: store.items,
                    categories: categoryStore.categories
                )
            } catch {
                showExportError = true
            }
        } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)   // 👈 centers the icon
                .contentShape(Rectangle())      // 👈 centers tap area
        }
        .sheet(item: $shareURL) { url in
            ShareLink(
                item: url,
                message: Text("Excel Export")
            )
        }
        .alert("Export failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Couldn’t create the export file. Try again.")
        }
    }
}

// MARK: - Identifiable conformance for URL
extension URL: Identifiable {
    public var id: String { absoluteString }
}
