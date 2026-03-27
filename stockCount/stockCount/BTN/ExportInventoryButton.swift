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
    @State private var isExporting = false

    var body: some View {
        Button {
            exportInventory()
        } label: {
            ZStack {
                if isExporting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
        }
        .disabled(isExporting)
        // ✅ Invalidate export on data change
        .onReceive(store.$items) { _ in shareURL = nil }
        .onReceive(categoryStore.$categories) { _ in shareURL = nil }
        .sheet(item: $shareURL) { url in
            ShareLink(item: url, message: Text("Excel Export"))
                .presentationDetents([.medium, .large])
        }
        .alert("Export Failed", isPresented: $showExportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Couldn't create the export file. Please try again.")
        }
    }

    // MARK: - Export Logic
    private func exportInventory() {
        guard !isExporting else { return }

        isExporting = true
        shareURL = nil

        // ✅ Run on background thread so UI doesn't freeze
        let items = store.items
        let categories = categoryStore.categories

        Task.detached(priority: .userInitiated) {
            do {
                InventoryExport.clearOldExports()

                let url = try InventoryExport.makeXLSXFile(
                    items: items,
                    categories: categories
                )

                // ✅ Back to main thread to update UI
                await MainActor.run {
                    shareURL = url
                    isExporting = false
                }

            } catch {
                await MainActor.run {
                    showExportError = true
                    isExporting = false
                }
            }
        }
    }
}

// MARK: - Identifiable conformance for URL
extension URL: Identifiable {
    public var id: String { absoluteString }
}
