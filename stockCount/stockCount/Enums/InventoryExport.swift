//
//  InventoryExport.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//



///  CSV file Format



//import Foundation
//
//enum InventoryExport {
//    
//    /// Creates a CSV file and returns its file URL.
//    static func makeCSVFile(items: [Clothes], categories: [Category]) throws -> URL {
//        // Map categoryId -> category name
//        let categoryMap: [String: String] = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })
//        
//        // CSV Header (edit columns if you want)
//        var lines: [String] = [
//            "Name,Description,Category,Quantity,Price,SalePrice,Color,Size,Season,Image,ID"
//        ]
//        
//        for item in items {
//            let categoryName = item.categoryId.flatMap { categoryMap[$0] } ?? item.categorie.rawValue
//            
//            let row: [String] = [
//                csv(item.name),
//                csv(item.description),
//                csv(categoryName),
//                "\(item.quantity)",
//                "\(item.price)",
//                "\(item.salePrice)",
//                csv(item.color.rawValue),
//                csv(item.size.rawValue),
//                csv(item.season.rawValue),
//                csv(item.image),
//                csv(item.id)
//            ]
//            
//            lines.append(row.joined(separator: ","))
//        }
//        
//        let csvText = lines.joined(separator: "\n")
//        let data = Data(csvText.utf8)
//        
//        // Save to temp (best for sharing/export)
//        let fileName = "stockCount_inventory_\(dateStamp()).csv"
//        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//        try data.write(to: url, options: .atomic)
//        return url
//    }
//    
//    // MARK: - Helpers
//    
//    private static func csv(_ value: String) -> String {
//        // Escape quotes and wrap in quotes if needed
//        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
//        if escaped.contains(",") || escaped.contains("\n") || escaped.contains("\"") {
//            return "\"\(escaped)\""
//        }
//        return escaped
//    }
//    
//    private static func dateStamp() -> String {
//        let f = DateFormatter()
//        f.dateFormat = "yyyy-MM-dd_HH-mm"
//        return f.string(from: Date())
//    }
//}


/// xlsx format

import Foundation
import libxlsxwriter

enum InventoryExport {

    // ✅ Real .xlsx export (formatted for Excel)
    static func makeXLSXFile(items: [Clothes], categories: [Category]) throws -> URL {

        // ✅ IMPORTANT: Clear old exports so you never share an older file by mistake
        clearOldExports()

        // Map categoryId -> name
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0.name) })

        // ✅ Unique filename every export
        let fileName = "stockCount_inventory_\(dateStamp())_\(UUID().uuidString).xlsx"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        guard let workbook = workbook_new(url.path) else {
            throw ExportError.failedToCreateWorkbook
        }
        defer { workbook_close(workbook) }

        // =========================
        // Sheet 1: Inventory
        // =========================
        guard let worksheet = workbook_add_worksheet(workbook, "Inventory") else {
            throw ExportError.failedToCreateWorksheet
        }

        // ===== Formats =====

        // Header (bold)
        let headerFormat = workbook_add_format(workbook)
        format_set_bold(headerFormat)
        format_set_align(headerFormat, UInt8(LXW_ALIGN_VERTICAL_TOP.rawValue))

        // Wrapped text (for long text cells)
        let wrapFormat = workbook_add_format(workbook)
        format_set_text_wrap(wrapFormat)
        format_set_align(wrapFormat, UInt8(LXW_ALIGN_VERTICAL_TOP.rawValue))

        // Normal text
        let normalFormat = workbook_add_format(workbook)
        format_set_align(normalFormat, UInt8(LXW_ALIGN_VERTICAL_TOP.rawValue))

        // ===== Sheet layout / formatting =====

        // Freeze header row
        worksheet_freeze_panes(worksheet, 1, 0)

        // Column widths (Excel units) — prevents text bleeding
        worksheet_set_column(worksheet, 0, 0, 22, nil) // Name
        worksheet_set_column(worksheet, 1, 1, 36, nil) // Description
        worksheet_set_column(worksheet, 2, 2, 18, nil) // Category
        worksheet_set_column(worksheet, 3, 3, 10, nil) // Quantity
        worksheet_set_column(worksheet, 4, 4, 12, nil) // Price
        worksheet_set_column(worksheet, 5, 5, 12, nil) // SalePrice
        worksheet_set_column(worksheet, 6, 6, 12, nil) // Color
        worksheet_set_column(worksheet, 7, 7, 10, nil) // Size
        worksheet_set_column(worksheet, 8, 8, 12, nil) // Season
        worksheet_set_column(worksheet, 9, 9, 18, nil) // Image
        worksheet_set_column(worksheet, 10, 10, 36, nil) // ID

        // ===== Headers =====
        let headers = [
            "Name",
            "Description",
            "Category",
            "Quantity",
            "Price",
            "SalePrice",
            "Color",
            "Size",
            "Season",
            "Image",
            "ID"
        ]

        for (col, title) in headers.enumerated() {
            writeString(worksheet, row: 0, col: col, title, format: headerFormat)
        }

        // ===== Rows =====
        for (index, item) in items.enumerated() {
            let r = index + 1

            // Prefer dynamic categories; fallback to enum rawValue if needed
            let categoryName: String = {
                if let id = item.categoryId, let name = categoryMap[id] { return name }
                return item.categorie.rawValue
            }()

            // Wrap name & description so they never spill
            writeString(worksheet, row: r, col: 0, item.name, format: wrapFormat)
            writeString(worksheet, row: r, col: 1, item.description, format: wrapFormat)

            // Regular text
            writeString(worksheet, row: r, col: 2, categoryName, format: normalFormat)

            // Numbers
            worksheet_write_number(worksheet, lxw_row_t(r), lxw_col_t(3), Double(item.quantity), nil)
            worksheet_write_number(worksheet, lxw_row_t(r), lxw_col_t(4), item.price, nil)
            worksheet_write_number(worksheet, lxw_row_t(r), lxw_col_t(5), item.salePrice, nil)

            // More text
            writeString(worksheet, row: r, col: 6, item.color.rawValue, format: normalFormat)
            writeString(worksheet, row: r, col: 7, item.size.rawValue, format: normalFormat)
            writeString(worksheet, row: r, col: 8, item.season.rawValue, format: normalFormat)
            writeString(worksheet, row: r, col: 9, item.image, format: normalFormat)
            writeString(worksheet, row: r, col: 10, item.id, format: normalFormat)
        }

        // =========================
        // Sheet 2: Debug (optional but VERY helpful)
        // This helps you confirm you're opening the newest export.
        // =========================
        if let debugSheet = workbook_add_worksheet(workbook, "DEBUG") {
            let bold = workbook_add_format(workbook)
            format_set_bold(bold)

            writeString(debugSheet, row: 0, col: 0, "Export Timestamp", format: bold)
            writeString(debugSheet, row: 0, col: 1, dateStamp())

            writeString(debugSheet, row: 1, col: 0, "Items Exported", format: bold)
            worksheet_write_number(debugSheet, lxw_row_t(1), lxw_col_t(1), Double(items.count), nil)

            writeString(debugSheet, row: 2, col: 0, "File Name", format: bold)
            writeString(debugSheet, row: 2, col: 1, fileName)

            worksheet_set_column(debugSheet, 0, 0, 20, nil)
            worksheet_set_column(debugSheet, 1, 1, 60, nil)
        }

        return url
    }

    // MARK: - Cleanup (Temp folder only)
    static func clearOldExports() {
        let temp = FileManager.default.temporaryDirectory
        let prefix = "stockCount_inventory_"

        if let files = try? FileManager.default.contentsOfDirectory(at: temp, includingPropertiesForKeys: nil) {
            for f in files where f.lastPathComponent.hasPrefix(prefix) {
                try? FileManager.default.removeItem(at: f)
            }
        }
    }

    // MARK: - Helpers
    private static func writeString(
        _ ws: UnsafeMutablePointer<lxw_worksheet>?,
        row: Int,
        col: Int,
        _ value: String,
        format: UnsafeMutablePointer<lxw_format>? = nil
    ) {
        // Keep it safe even if empty
        let safe = value
        safe.withCString { cstr in
            worksheet_write_string(ws, lxw_row_t(row), lxw_col_t(col), cstr, format)
        }
    }

    private static func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return f.string(from: Date())
    }
}

enum ExportError: Error {
    case failedToCreateWorkbook
    case failedToCreateWorksheet
}
