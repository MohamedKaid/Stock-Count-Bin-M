//
//  HomeView.swift
//  stockCount
//
//  Created by Mohamed Kaid on 11/14/25.
//

import SwiftUI
import StoreKit

struct HomeView: View {
    @EnvironmentObject private var store: InventoryStore
    @EnvironmentObject private var categoryStore: CategoryStore
    @State private var navigateToAddItem = false
    @State private var didRunMigration = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var totalUnits: Int {
        store.items.reduce(0) { $0 + $1.quantity }
    }

    private var totalCategories: Int {
        categoryStore.categories.count
    }

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

            VStack(spacing: 20) {

                // MARK: Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BIN MUKHTAR RETAIL")
                            .font(.title2.weight(.heavy))
                            .foregroundStyle(.white)

                        Text("Inventory Dashboard")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()

                    // Avatar
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

                        Text("BM")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.top, 4)

                // MARK: Stats Row
                HStack(spacing: 12) {
                    // Categories stat
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.callout)
                            .foregroundStyle(Color(hex: "7B61FF"))

                        Text("\(totalCategories)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Categories")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "7B61FF").opacity(0.3), lineWidth: 1)
                    )

                    // Total units stat
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: "shippingbox.fill")
                            .font(.callout)
                            .foregroundStyle(Color(hex: "4A90E2"))

                        Text("\(totalUnits)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Total Units")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: "4A90E2").opacity(0.3), lineWidth: 1)
                    )
                }

                // MARK: Categories Label + Manage Button
                HStack {
                    Text("Categories")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)

                    Spacer()

                    NavigationLink {
                        ManageCategoriesView()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.caption)
                            Text("ADD / DELETE")
                                .font(.caption.weight(.bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.1))
                        .clipShape(Capsule())
                        .foregroundStyle(.white)
                    }
                }

                // MARK: Category Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(categoryStore.categories) { category in
                            let itemCount = store.items(in: category.id).count
                            let totalQty = store.totalQuantity(in: category.id)

                            NavigationLink {
                                CategoryItemsView(category: category)
                            } label: {
                                // Restyled category card
                                VStack(alignment: .leading, spacing: 10) {

                                    // Icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(hex: "7B61FF").opacity(0.15))
                                            .frame(width: 36, height: 36)

                                        Image(systemName: "hanger")
                                            .font(.callout)
                                            .foregroundStyle(Color(hex: "7B61FF"))
                                    }

                                    // Category name
                                    Text(category.name)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    // Item + qty info
                                    Text("\(itemCount) items • \(totalQty) qty")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(.white.opacity(0.06))
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(.white.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                    .padding(.bottom, 100)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                guard !didRunMigration else { return }
                didRunMigration = true
                store.repairCategoriesFromStorage(using: categoryStore)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ExportInventoryButton()
                }
            }
            .navigationDestination(isPresented: $navigateToAddItem) {
                AddItemView()
            }

            // MARK: Floating Add Button
            VStack {
                Spacer()
                Button {
                    navigateToAddItem = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Add to Wardrobe")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(
                        color: Color(hex: "7B61FF").opacity(0.5),
                        radius: 12,
                        y: 6
                    )
                    .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(InventoryStore())
            .environmentObject(CategoryStore())
    }
}
