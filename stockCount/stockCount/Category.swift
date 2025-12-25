//
//  Category.swift
//  stockCount
//
//  Created by Mohamed Kaid on 12/25/25.
//

import Foundation

struct Category: Identifiable, Codable, Equatable {
    let id: String
    var name: String

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }

    // Backward compatible: if old JSON had createdAt, ignore it
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
}
