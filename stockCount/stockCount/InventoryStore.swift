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
    
    func delete(_ item: Clothes) {
        items.removeAll { $0.id == item.id }
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

