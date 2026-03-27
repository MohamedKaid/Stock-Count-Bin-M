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
    @State private var category: Categories = .longSleeves
    @State private var size: Sizes = .NA
    @State private var customSize: CustomSizes = .none
    @State private var season: Season = .Summer
    @State private var color: ColorChoice = .black

    // MARK: - Draft
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

    private func formatMoney(_ value: Double) -> String {
        String(format: "%.2f", value)
    }

    private func saveDraft(from item: Clothes) {
        do {
            let data = try JSONEncoder().encode(item)
            lastItemDraftData = data
        } catch {}
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
        if !clearQuantity { quantity = "\(draft.quantity)" }
        selectedCategoryId = draft.categoryId ?? ""
        category = draft.categorie
        size = draft.size
        customSize = draft.customSize
        season = draft.season
        color = draft.color
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
            categoryId: selectedCategoryId.isEmpty ? nil : selectedCategoryId,
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

        saveDraft(from: item)
        dismiss()
    }

    // MARK: - Body
    var body: some View {
        ZStack {

            // MARK: Background
            LinearGradient(
                colors: [
                    Color(hex: "0D0D1A"),
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative blur circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 300)
                    .blur(radius: 60)
                    .offset(x: -50, y: -80)

                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 250)
                    .blur(radius: 60)
                    .offset(
                        x: geo.size.width - 150,
                        y: geo.size.height * 0.3
                    )
            }
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isEditing ? "Edit Item" : "Add Item")
                                .font(.title2.weight(.heavy))
                                .foregroundStyle(.white)

                            Text(isEditing ? "Update the details below" : "Fill the details below")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                        }

                        Spacer()

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "7B61FF"),
                                            Color(hex: "4A90E2")
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)

                            Image(systemName: isEditing ? "pencil" : "plus")
                                .font(.callout.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 4)

                    // MARK: Quick Actions Card
                    sectionCard {
                        sectionLabel("Quick Actions", icon: "wand.and.stars")

                        Toggle(isOn: $autoFillLastItem) {
                            Text("Auto-fill from last item")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .tint(Color(hex: "7B61FF"))

                        Button {
                            applyDraft(clearQuantity: true)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Use Last Item")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                hasDraft
                                ? LinearGradient(
                                    colors: [Color(hex: "7B61FF"), Color(hex: "4A90E2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    colors: [.white.opacity(0.1), .white.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                        }
                        .disabled(!hasDraft)
                        .opacity(hasDraft ? 1 : 0.5)
                    }

                    // MARK: Item Info Card
                    sectionCard {
                        sectionLabel("Item Info", icon: "tag.fill")

                        styledTextField(
                            placeholder: "Name (ex: Hoodie)",
                            text: $name
                        )
                        .textInputAutocapitalization(.words)

                        styledTextField(
                            placeholder: "Description (optional)",
                            text: $description,
                            axis: .vertical
                        )

                        // Prices
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Cost Price")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))

                                styledTextField(
                                    placeholder: "0.00",
                                    text: $costPrice
                                )
                                .keyboardType(.decimalPad)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Sale Price")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))

                                styledTextField(
                                    placeholder: "0.00",
                                    text: $salePrice
                                )
                                .keyboardType(.decimalPad)
                            }
                        }

                        // Profit + Margin Pills
                        HStack(spacing: 10) {
                            profitPill(
                                title: "Profit",
                                value: "$\(formatMoney(profitValue))",
                                icon: "banknote",
                                color: profitValue >= 0
                                    ? Color(hex: "4CAF50")
                                    : Color(hex: "FF6B6B")
                            )

                            profitPill(
                                title: "Margin",
                                value: "\(Int(marginPercent))%",
                                icon: "percent",
                                color: marginPercent >= 0
                                    ? Color(hex: "4A90E2")
                                    : Color(hex: "FF6B6B")
                            )
                        }
                    }

                    // MARK: Stock & Attributes Card
                    sectionCard {
                        sectionLabel("Stock & Attributes", icon: "shippingbox.fill")

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Quantity")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))

                            styledTextField(
                                placeholder: "0",
                                text: $quantity
                            )
                            .keyboardType(.numberPad)
                        }

                        Divider()
                            .background(.white.opacity(0.1))

                        // Pickers
                        styledPicker(label: "Category") {
                            Picker("Category", selection: $selectedCategoryId) {
                                ForEach(categoryStore.categories) { c in
                                    Text(c.name).tag(c.id)
                                }
                            }
                            .tint(.white)
                        }

                        styledPicker(label: "Size") {
                            Picker("Size", selection: $size) {
                                ForEach(Sizes.allCases, id: \.self) { s in
                                    Text(s.rawValue.uppercased()).tag(s)
                                }
                            }
                            .tint(.white)
                        }

                        styledPicker(label: "Custom Size") {
                            Picker("Custom Size", selection: $customSize) {
                                ForEach(CustomSizes.allCases, id: \.self) { s in
                                    Text(s.rawValue.uppercased()).tag(s)
                                }
                            }
                            .tint(.white)
                        }

                        styledPicker(label: "Season") {
                            Picker("Season", selection: $season) {
                                ForEach(Season.allCases, id: \.self) { s in
                                    Text(s.rawValue.capitalized).tag(s)
                                }
                            }
                            .tint(.white)
                        }

                        styledPicker(label: "Color") {
                            Picker("Color", selection: $color) {
                                ForEach(ColorChoice.allCases, id: \.self) { c in
                                    Text(c.rawValue.capitalized).tag(c)
                                }
                            }
                            .tint(.white)
                        }
                    }

                    // MARK: Bottom Buttons
                    HStack(spacing: 10) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.white.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                )
                        }

                        Button {
                            saveItem()
                        } label: {
                            Text(isEditing ? "Save Changes" : "Add Item")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "7B61FF"),
                                            Color(hex: "4A90E2")
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(
                                    color: Color(hex: "7B61FF").opacity(0.4),
                                    radius: 8,
                                    y: 4
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 24)
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

            if autoFillLastItem, hasDraft {
                applyDraft(clearQuantity: true)
            }
        }
    }

    // MARK: - Reusable UI Helpers

    // Section Card
    @ViewBuilder
    private func sectionCard<Content: View>(
        @ViewBuilder _ content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    // Section Label
    private func sectionLabel(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(Color(hex: "7B61FF"))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
    }

    // Styled TextField
    private func styledTextField(
        placeholder: String,
        text: Binding<String>,
        axis: Axis = .horizontal
    ) -> some View {
        TextField(placeholder, text: text, axis: axis)
            .foregroundStyle(.white)
            .tint(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
    }

    // Styled Picker Row
    @ViewBuilder
    private func styledPicker<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Spacer()

            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // Profit / Margin Pill
    private func profitPill(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                Text(value)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Keyboard Helper
private extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddItemView()
            .environmentObject(InventoryStore())
            .environmentObject(CategoryStore())
    }
}
