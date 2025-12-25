import SwiftUI

struct CategoryItemsView: View {
    @EnvironmentObject private var store: InventoryStore
    @State private var showAdd = false

    let category: Category

    private var items: [Clothes] {
        store.items(in: category.id)
    }


    var body: some View {
        List {
            if items.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tray")
                        .font(.system(size: 34))
                        .foregroundStyle(.secondary)

                    Text("No items yet")
                        .font(.headline)

                    Text("Tap Add to create your first item in this category.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowBackground(Color.clear)
            } else {
                ForEach(items) { item in
                    NavigationLink {
                        AddItemView(editItem: item)   // edit mode
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)

                                Spacer()

                                Text("Qty \(item.quantity)")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            Text("\(item.color.rawValue.capitalized) • Cost \(item.price, specifier: "%.2f") • Sale \(item.salePrice, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            store.delete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                AddItemView()
                    .environmentObject(store)
            }
        }
    }
}
