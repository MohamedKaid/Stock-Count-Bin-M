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

    var body: some View {
        ZStack {
            Color.nightBlueShadow
                .ignoresSafeArea(.all)

            VStack(spacing: 20) {

                // Header
                VStack(alignment: .center, spacing: 4) {
                    Text("BIN MUKHTAR RETAIL")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 25) {
                        Text("Inventory Dashboard")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }

                // Categories title row
                HStack {
                    Text("Categories")
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white)

                    Spacer()

                    NavigationLink {
                        ManageCategoriesView()
                    } label: {
                        Text("ADD / DELETE")
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.glassProminent)
                }
                .padding(.top, 4)

                // Category grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(categoryStore.categories) { category in
                            let itemCount = store.items(in: category.id).count
                            let totalQty = store.totalQuantity(in: category.id)

                            NavigationLink {
                                CategoryItemsView(category: category)
                            } label: {
                                categorieCard(
                                    categoryImage: "",
                                    categoryLable: category.name,
                                    numberOfItems: "\(itemCount) items • \(totalQty) qty"
                                )
                            }
                            .buttonStyle(.plain)
                            .preferredColorScheme(.light)
                        }
                    }
                    .padding(.horizontal)
                }

                // Primary CTA
                Button {
                    navigateToAddItem = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add to Wardrobe")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.glassProminent)
            }
            .padding()
            .onAppear {
                guard !didRunMigration else { return }
                didRunMigration = true

                // ✅ Runs:
                // 1) legacy enum -> dynamic categoryId migration
                // 2) rebuild any missing categories referenced by items
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
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(InventoryStore())
            .environmentObject(CategoryStore())
    }
}
