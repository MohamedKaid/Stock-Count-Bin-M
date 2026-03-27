import SwiftUI

struct CategoryItemsView: View {
    @EnvironmentObject private var store: InventoryStore
    @State private var showAdd = false

    let category: Category

    private var items: [Clothes] {
        store.items(in: category.id)
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

            // MARK: Content
            if items.isEmpty {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(items) { item in
                            NavigationLink {
                                AddItemView(editItem: item)
                            } label: {
                                itemCard(item: item)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.delete(id: item.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAdd = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.callout.weight(.bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
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
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
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

    // MARK: - Item Card
    private func itemCard(item: Clothes) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Top row - name + quantity badge
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(item.color.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                // Quantity badge
                Text("Qty \(item.quantity)")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        item.quantity == 0
                        ? Color(hex: "FF6B6B").opacity(0.15)
                        : Color(hex: "4CAF50").opacity(0.15)
                    )
                    .foregroundStyle(
                        item.quantity == 0
                        ? Color(hex: "FF6B6B")
                        : Color(hex: "4CAF50")
                    )
                    .clipShape(Capsule())
            }

            Divider()
                .background(.white.opacity(0.08))

            // Bottom row - cost + sale price
            HStack(spacing: 12) {
                priceTag(
                    label: "Cost",
                    value: String(format: "%.2f", item.price),
                    color: Color(hex: "4A90E2")
                )

                priceTag(
                    label: "Sale",
                    value: String(format: "%.2f", item.salePrice),
                    color: Color(hex: "7B61FF")
                )

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(14)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Price Tag
    private func priceTag(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))

            Text("$\(value)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "7B61FF").opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "tray.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: "7B61FF").opacity(0.6))
            }

            Text("No items yet")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Tap the + button to add your\nfirst item in this category.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}
