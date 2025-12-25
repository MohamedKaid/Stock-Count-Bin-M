//
//  InventoryExport.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import Foundation

enum InventoryExport {
    
    /// Creates a CSV file and returns its file URL.
    static func makeCSVFile(items: [Clothes], categories: [Category]) throws -> URL {
        // Map categoryId -> category name
        let categoryMap: [String: String] = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
        
        // CSV Header (edit columns if you want)
        var lines: [String] = [
            "Name,Description,Category,Quantity,Price,SalePrice,Color,Size,Season,Image,ID"
        ]
        
        for item in items {
            let categoryName = item.categoryId.flatMap { categoryMap[$0] } ?? item.categorie.rawValue
            
            let row: [String] = [
                csv(item.name),
                csv(item.description),
                csv(categoryName),
                "\(item.quantity)",
                "\(item.price)",
                "\(item.salePrice)",
                csv(item.color.rawValue),
                csv(item.size.rawValue),
                csv(item.season.rawValue),
                csv(item.image),
                csv(item.id)
            ]
            
            lines.append(row.joined(separator: ","))
        }
        
        let csvText = lines.joined(separator: "\n")
        let data = Data(csvText.utf8)
        
        // Save to temp (best for sharing/export)
        let fileName = "stockCount_inventory_\(dateStamp()).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }
    
    // MARK: - Helpers
    
    private static func csv(_ value: String) -> String {
        // Escape quotes and wrap in quotes if needed
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
            return "\"\(escaped)\""
        }
        return escaped
    }
    
    private static func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm"
        return f.string(from: Date())
    }
}
