//
//  ManageCategoriesView.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import SwiftUI

struct ManageCategoriesView: View {
    @EnvironmentObject private var categoryStore: CategoryStore
    @State private var newName: String = ""

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
                    for i in indexSet {
                        let id = categoryStore.categories[i].id
                        categoryStore.deleteCategory(id: id)
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .toolbar {
            EditButton()   // ✅ add this
        }
    }
}

#Preview {
    NavigationStack {
        ManageCategoriesView()
            .environmentObject(CategoryStore())
    }
}

