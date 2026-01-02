//
//  ManageCategoriesView.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject private var categoryStore: CategoryStore
    @EnvironmentObject private var store: InventoryStore   // ✅ needed to delete items too

    @State private var newName: String = ""

    // ✅ Alert state
    @State private var showDeleteAlert = false
    @State private var categoryPendingDelete: Category? = nil

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField("New category", text: $newName)
                    .font(.system(size: 22))
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    categoryStore.addCategory(name: newName)
                    newName = ""
                }
            }
            .padding(.horizontal)

            List {
                ForEach(categoryStore.categories) { cat in
                    Text(cat.name)
                }
                .onDelete { indexSet in
                    // ✅ Only handle the first one (simple and safe)
                    // You can expand to multiple later if you want
                    if let first = indexSet.first {
                        categoryPendingDelete = categoryStore.categories[first]
                        showDeleteAlert = true
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            EditButton()
        }
        // ✅ Confirmation Alert
        .alert("Delete Category?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                guard let cat = categoryPendingDelete else { return }

                // ✅ Delete the category AND its inventory
                categoryStore.deleteCategoryAndItems(id: cat.id) { categoryId in
                    store.deleteItems(in: categoryId)
                }

                categoryPendingDelete = nil
            }

            Button("Cancel", role: .cancel) {
                categoryPendingDelete = nil
            }
        } message: {
            if let cat = categoryPendingDelete {
                Text("This will permanently delete “\(cat.name)” and ALL items inside it. This cannot be undone.")
            } else {
                Text("This will permanently delete the category and ALL items inside it.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageCategoriesView()
            .environmentObject(CategoryStore())
            .environmentObject(InventoryStore())
    }
}
