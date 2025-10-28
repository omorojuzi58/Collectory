import SwiftUI

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

struct CollectionScreen: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                contentView
                floatingButton
            }
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
    
    private var backgroundView: some View {
        ThemeManager.primaryGradient
            .opacity(0.1)
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if dataManager.getCollectionItems().isEmpty {
            emptyStateView
        } else {
            collectionGridView
        }
    }
    
    private var emptyStateView: some View {
        EmptyStateView(
            icon: "square.grid.2x2",
            title: "Collection is empty",
            message: "Add your first item to the collection"
        )
    }
    
    private var collectionGridView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<chunkedItems.count, id: \.self) { index in
                    itemRowView(for: chunkedItems[index])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
    
    private var chunkedItems: [[Item]] {
        Array(dataManager.getCollectionItems().chunked(into: 2))
    }
    
    private func itemRowView(for rowItems: [Item]) -> some View {
        HStack(spacing: 16) {
            ForEach(rowItems) { item in
                NavigationLink(destination: ItemDetailView(item: item)) {
                    ItemCard(item: item)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            if rowItems.count == 1 {
                Spacer()
            }
        }
    }
    
    private var floatingButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                GradientFloatingButton(icon: "plus") {
                    showingAddItem = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct ItemCard: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            imageView
            contentView
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var imageView: some View {
        Group {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(height: 140)
                    .clipped()
            } else {
                placeholderImage
            }
        }
        .cornerRadius(12)
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .font(.system(size: 40))
            .foregroundColor(ThemeManager.secondaryText)
            .frame(height: 140)
            .frame(maxWidth: .infinity)
            .background(ThemeManager.secondaryText.opacity(0.1))
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleText
            categoryText
            conditionBadge
        }
        .padding(.horizontal, 4)
    }
    
    private var titleText: some View {
        Text(item.name)
            .font(ThemeManager.headlineFont)
            .foregroundColor(ThemeManager.primaryText)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
    }
    
    private var categoryText: some View {
        Text(item.category)
            .font(ThemeManager.captionFont)
            .foregroundColor(ThemeManager.secondaryText)
            .lineLimit(1)
    }
    
    private var conditionBadge: some View {
        HStack {
            Text(item.condition.rawValue)
                .font(ThemeManager.smallFont)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(item.condition.color.opacity(0.15))
                .foregroundColor(item.condition.color)
                .cornerRadius(8)
            
            Spacer()
        }
    }
}

#Preview {
    CollectionScreen()
}
