//
//  Clothes.swift
//  stockCount
//
//  Created by Mohamed Kaid on 11/13/25.
//


import Foundation

struct Clothes: Identifiable, Codable {
    var id: String = UUID().uuidString

    var name: String
    var description: String
    var price: Double
    var salePrice: Double = 0.0
    var quantity: Int
    var color: ColorChoice = .black
    var image: String

    // ✅ NEW (for dynamic categories)
    var categoryId: String? = nil

    // ✅ Keep old enum for now (minimal change)
    var categorie: Categories = .longSleeves

    var size: Sizes = .NA
    var customSize: CustomSizes = .none
    var season: Season = .Summer
}



