//
//  CategoryStore.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import SwiftUI
import Foundation
import Combine

final class CategoryStore: ObservableObject {
    @Published private(set) var categories: [Category] = []

    private let fileName = "categories.json"

    init() {
        load()
        if categories.isEmpty {
            // Default starter categories (optional)
            categories = [
                Category(name: "Long Sleeves"),
                Category(name: "Hoodies"),
                Category(name: "Pants")
            ]
            save()
        }
    }

    // MARK: - CRUD

    func addCategory(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !categories.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) else { return }

        categories.append(Category(name: trimmed))
        categories.sort { $0.name.lowercased() < $1.name.lowercased() }
        save()
    }

    /// ✅ NEW: Create or update a category with a specific ID.
    /// Useful for repairing storage when items reference a categoryId that doesn't exist anymore.
    func upsertCategory(id: String, name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // If a category with this ID exists, rename it.
        if let idx = categories.firstIndex(where: { $0.id == id }) {
            categories[idx].name = trimmed
            categories.sort { $0.name.lowercased() < $1.name.lowercased() }
            save()
            return
        }

        // If a category with this name exists already, do nothing (avoid duplicates)
        if categories.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            return
        }

        // Otherwise create with the requested ID
        categories.append(Category(id: id, name: trimmed))
        categories.sort { $0.name.lowercased() < $1.name.lowercased() }
        save()
    }

    func renameCategory(id: String, newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        guard let idx = categories.firstIndex(where: { $0.id == id }) else { return }
        categories[idx].name = trimmed
        categories.sort { $0.name.lowercased() < $1.name.lowercased() }
        save()
    }

    /// Basic delete (category only)
    func deleteCategory(id: String) {
        categories.removeAll { $0.id == id }
        save()
    }

    /// ✅ NEW: Delete category AND also delete all inventory items in that category.
    /// We use a closure so CategoryStore doesn't depend on InventoryStore directly.
    ///
    /// Usage from a View:
    /// categoryStore.deleteCategoryAndItems(id: cat.id) { categoryId in
    ///     store.deleteItems(in: categoryId)
    /// }
    func deleteCategoryAndItems(id: String, deleteItems: (String) -> Void) {
        // 1) delete items first
        deleteItems(id)

        // 2) delete category
        categories.removeAll { $0.id == id }
        save()
    }

    // MARK: - Persistence

    private func fileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL())
            categories = try JSONDecoder().decode([Category].self, from: data)
        } catch {
            categories = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: fileURL(), options: [.atomic])
        } catch {
            // optionally log
        }
    }
}
