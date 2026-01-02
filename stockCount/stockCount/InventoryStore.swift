import Foundation
import Combine

@MainActor
final class InventoryStore: ObservableObject {

    @Published var items: [Clothes] = [] {
        didSet { saveToDisk() }
    }

    private let fileName = "inventory.json"

    init() {
        loadFromDisk()
    }

    func add(_ item: Clothes) {
        items.append(item)
    }

    func update(_ item: Clothes) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
    }

    func delete(id: String) {
        items.removeAll { $0.id == id }
    }

    func deleteItems(in categoryId: String) {
        items.removeAll { $0.categoryId == categoryId }
    }

    // ✅ OLD system (keep if still used anywhere)
    func items(in category: Categories) -> [Clothes] {
        items.filter { $0.categorie == category }
    }

    func totalQuantity(in category: Categories) -> Int {
        items(in: category).reduce(0) { $0 + $1.quantity }
    }

    // MARK: - Persistence

    private func fileURL() -> URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent(fileName)
    }

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL(), options: [.atomic])
        } catch {
            print("❌ Save failed:", error.localizedDescription)
        }
    }

    private func loadFromDisk() {
        let url = fileURL()
        guard FileManager.default.fileExists(atPath: url.path) else { return }

        do {
            let data = try Data(contentsOf: url)
            items = try JSONDecoder().decode([Clothes].self, from: data)
        } catch {
            print("❌ Load failed:", error.localizedDescription)
        }
    }
}

// ✅ MUST be outside the class
extension InventoryStore {

    // ✅ NEW system
    func items(in categoryId: String) -> [Clothes] {
        items.filter { $0.categoryId == categoryId }
    }

    func totalQuantity(in categoryId: String) -> Int {
        items(in: categoryId).reduce(0) { $0 + $1.quantity }
    }

    func clearCategoryReferences(categoryId: String) {
        for i in items.indices where items[i].categoryId == categoryId {
            items[i].categoryId = nil
        }
    }
}

// ✅ Legacy category migration (SAFE, one-time)
extension InventoryStore {

    /// Assigns categoryId to items created before dynamic categories existed
    func migrateLegacyItemsIfNeeded(using categoryStore: CategoryStore) {

        let legacyMap: [Categories: String] = [
            .longSleeves: "Long Sleeves",
            .shortSleves: "Short Sleeves",
            .accessories: "Accessories",
            .bottoms: "Bottoms"
        ]

        func findCategoryId(named name: String) -> String? {
            categoryStore.categories.first {
                $0.name.lowercased() == name.lowercased()
            }?.id
        }

        var didChange = false

        for i in items.indices {
            guard items[i].categoryId == nil else { continue }

            let targetName = legacyMap[items[i].categorie] ?? "Uncategorized"

            if findCategoryId(named: targetName) == nil {
                categoryStore.addCategory(name: targetName)
            }

            if let id = findCategoryId(named: targetName) {
                items[i].categoryId = id
                didChange = true
            }
        }

        if didChange {
            items = items   // triggers saveToDisk safely
        }
    }
}

// ✅ NEW: Storage repair (categories)
extension InventoryStore {

    /// Runs on app launch:
    /// 1) migrate legacy enum categories -> dynamic categoryId
    /// 2) ensure any categoryId referenced by items exists in CategoryStore
    ///
    /// If a categoryId is missing, we recreate it using the same id.
    func repairCategoriesFromStorage(using categoryStore: CategoryStore) {

        // 1) migrate old items first
        migrateLegacyItemsIfNeeded(using: categoryStore)

        // 2) build a set of existing category IDs
        let existingIds = Set(categoryStore.categories.map { $0.id })

        // 3) collect categoryIds referenced by items
        let referencedIds = Set(items.compactMap { $0.categoryId })

        // 4) find missing category ids
        let missingIds = referencedIds.subtracting(existingIds)
        guard !missingIds.isEmpty else { return }

        // 5) recreate missing categories (best effort naming)
        // We may not know the original name anymore, so we use a consistent placeholder.
        // You can rename later in ManageCategories.
        for missingId in missingIds {
            let placeholderName = "Recovered Category"
            categoryStore.upsertCategory(id: missingId, name: placeholderName)
        }
    }
}
