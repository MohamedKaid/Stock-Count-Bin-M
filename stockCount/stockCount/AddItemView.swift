//
//  AddItemView.swift
//  stockCount
//

import SwiftUI
import Combine
import UIKit

struct AddItemView: View {
    @EnvironmentObject private var store: InventoryStore
    @EnvironmentObject private var categoryStore: CategoryStore
    @Environment(\.dismiss) private var dismiss

    var editItem: Clothes? = nil

    // MARK: - Form fields
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var costPrice: String = ""
    @State private var salePrice: String = ""
    @State private var quantity: String = ""

    @State private var selectedCategoryId: String = ""
    // ✅ Keep old enum category for backward compatibility (minimal change)
    @State private var category: Categories = .longSleeves

    @State private var size: Sizes = .NA
    @State private var customSize: CustomSizes = .none
    @State private var season: Season = .Summer
    @State private var color: ColorChoice = .black

    // MARK: - Remember last item (draft)
    @AppStorage("lastItemDraftData") private var lastItemDraftData: Data = Data()
    @AppStorage("autoFillLastItem") private var autoFillLastItem: Bool = true

    private var hasDraft: Bool { !lastItemDraftData.isEmpty }

    private var isEditing: Bool { editItem != nil }

    private var parsedCost: Double? { Double(costPrice.replacingOccurrences(of: ",", with: ".")) }
    private var parsedSale: Double? { Double(salePrice.replacingOccurrences(of: ",", with: ".")) }
    private var parsedQty: Int? { Int(quantity) }

    private var profitValue: Double {
        guard let cost = parsedCost, let sale = parsedSale else { return 0 }
        return sale - cost
    }

    private var marginPercent: Double {
        guard let cost = parsedCost, let sale = parsedSale, cost > 0 else { return 0 }
        return ((sale - cost) / cost) * 100
    }

    private func saveDraft(from item: Clothes) {
        do {
            let data = try JSONEncoder().encode(item)
            lastItemDraftData = data
        } catch {
            // ignore
        }
    }

    private func draftItem() -> Clothes? {
        guard !lastItemDraftData.isEmpty else { return nil }
        do {
            return try JSONDecoder().decode(Clothes.self, from: lastItemDraftData)
        } catch {
            return nil
        }
    }

    private func applyDraft(clearQuantity: Bool) {
        guard let draft = draftItem() else { return }
        name = draft.name
        description = draft.description
        costPrice = formatMoney(draft.price)
        salePrice = formatMoney(draft.salePrice)
        if !clearQuantity {
            quantity = "\(draft.quantity)"
        }
        selectedCategoryId = draft.categoryId ?? ""
        category = draft.categorie
        size = draft.size
        customSize = draft.customSize
        season = draft.season
        color = draft.color
    }

    private func formatMoney(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private func saveItem() {
        guard let cost = parsedCost,
              let sale = parsedSale,
              let qty = parsedQty else { return }

        let item = Clothes(
            id: editItem?.id ?? UUID().uuidString,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            price: cost,
            salePrice: sale,
            quantity: qty,
            color: color,
            image: editItem?.image ?? "placeholder",

            // ✅ NEW LINE (that’s it)
            categoryId: selectedCategoryId.isEmpty ? nil : selectedCategoryId,

            // ✅ OLD LINE (kept for now)
            categorie: category,

            size: size,
            customSize: customSize,
            season: season
        )

        if isEditing {
            store.update(item)
        } else {
            store.add(item)
        }

        // remember last item (without forcing it)
        saveDraft(from: item)

        dismiss()
    }

    // MARK: - Card UI
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .center, spacing: 12) {
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func pill(_ title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.subheadline)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    var body: some View {
        ZStack {
            Color.nightBlue
                .ignoresSafeArea()

            ScrollView {
                // Tap anywhere to dismiss the keyboard
                // (keeps the UI the same)
                VStack(spacing: 14) {

                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isEditing ? "Edit Item" : "Add Item")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("Fill the details below.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Quick actions
                    card {
                        Toggle(isOn: $autoFillLastItem) {
                            Label("Auto-fill from last item", systemImage: "wand.and.stars")
                                .foregroundStyle(.white)
                        }
                        .tint(.green)

                        Button {
                            applyDraft(clearQuantity: true)
                        } label: {
                            Label("Use Last Item", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(!hasDraft)
                        .opacity(hasDraft ? 1 : 0.5)
                    }

                    // Item info
                    card {
                        Text("Item Info")
                            .font(.headline)
                            .foregroundStyle(.white)

                        TextField("Name (ex: Hoodie)", text: $name)
                            .textInputAutocapitalization(.words)
                            .textFieldStyle(.roundedBorder)

                        TextField("Description (optional)", text: $description, axis: .vertical)
                            .lineLimit(3, reservesSpace: true)
                            .textFieldStyle(.roundedBorder)

                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Cost Price")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                TextField("0.00", text: $costPrice)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sale Price")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                TextField("0.00", text: $salePrice)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }

                        HStack(alignment: .center, spacing: 10) {
                            pill("Profit", value: "$\(formatMoney(profitValue))", systemImage: "banknote")
                            pill("Margin", value: "\(Int(marginPercent))%", systemImage: "percent")
                        }
                    }

                    // Stock + Attributes
                    card {
                        Text("Stock & Attributes")
                            .font(.headline)
                            .foregroundStyle(.white)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                            TextField("0", text: $quantity)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                        }

                        HStack {
                            Text("Category:")
                                .foregroundStyle(.white)

                            Spacer()

                            Picker("Category", selection: $selectedCategoryId) {
                                ForEach(categoryStore.categories) { c in
                                    Text(c.name).tag(c.id)
                                }
                            }
                            .tint(.white)
                        }

                        HStack{
                            Text("Size:")
                                .foregroundStyle(.white)
                            Spacer()
                            Picker("Size", selection: $size) {
                                ForEach(Sizes.allCases, id: \.self) { s in
                                    Text(s.rawValue.uppercased()).tag(s)
                                }
                            }
                            .tint(.white)

                        }
                        HStack{
                            Text("Custom size:")
                                .foregroundStyle(.white)

                            Spacer()
                            Picker("custom size", selection: $customSize) {
                                ForEach(CustomSizes.allCases, id: \.self) { s in
                                    Text(s.rawValue.uppercased()).tag(s)
                                }
                            }
                            .tint(.white)
                        }

                        HStack{
                            Text("Season:")
                                .foregroundStyle(.white)
                            Spacer()
                            Picker("Season", selection: $season) {
                                ForEach(Season.allCases, id: \.self) { s in
                                    Text(s.rawValue.capitalized).tag(s)
                                }
                            }
                            .tint(.white)
                        }
                        HStack{
                            Text("Color:")
                                .foregroundStyle(.white)
                            Spacer()
                            Picker("Color", selection: $color) {
                                ForEach(ColorChoice.allCases, id: \.self) { c in
                                    Text(c.rawValue.capitalized).tag(c)

                                }
                            }
                            .tint(.white)
                        }
                    }

                    // Bottom buttons
                    HStack(spacing: 10) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.glass)

                        Button {
                            saveItem()
                        } label: {
                            Text(isEditing ? "Save Changes" : "Add Item")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.glassProminent)
                    }
                    .padding(.bottom, 8)
                }
                .padding()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { hideKeyboard() }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Editing fills from item
            if let item = editItem {
                name = item.name
                description = item.description
                costPrice = formatMoney(item.price)
                salePrice = formatMoney(item.salePrice)
                quantity = "\(item.quantity)"
                category = item.categorie
                selectedCategoryId = item.categoryId ?? ""
                size = item.size
                customSize = item.customSize
                season = item.season
                color = item.color
                return
            }

            // Add mode optional autofill
            if autoFillLastItem, hasDraft {
                applyDraft(clearQuantity: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddItemView()
            .environmentObject(InventoryStore())
            .environmentObject(CategoryStore())
    }
}

// MARK: - Keyboard helper
private extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
