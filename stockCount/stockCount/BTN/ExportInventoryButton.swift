//
//  ExportInventoryButton.swift
//  stockCount
//

import SwiftUI
import Combine

struct ExportInventoryButton: View {
    @EnvironmentObject private var store: InventoryStore
    @EnvironmentObject private var categoryStore: CategoryStore

    @State private var showExportError = false
    @State private var shareURL: URL? = nil

    var body: some View {
        Button {
            do {
                InventoryExport.clearOldExports()   // ✅ clears old temp exports
                shareURL = try InventoryExport.makeXLSXFile(
                    items: store.items,             // ✅ uses current list (after delete)
                    categories: categoryStore.categories
                )
            } catch {
                showExportError = true
            }
        } label: {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        // ✅ If anything changes, invalidate the last export
        .onReceive(store.$items) { _ in shareURL = nil }
        .onReceive(categoryStore.$categories) { _ in shareURL = nil }

        .sheet(item: $shareURL) { url in
            ShareLink(item: url, message: Text("Excel Export"))
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
