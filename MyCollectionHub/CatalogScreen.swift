import SwiftUI

struct CatalogScreen: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var searchText = ""
    @State private var sortOption: SortOption = .name
    
    enum SortOption: String, CaseIterable {
        case name = "By Name"
        case date = "By Purchase Date"
    }
    
    var filteredAndSortedItems: [Item] {
        let allItems = dataManager.items
        
        let filtered = searchText.isEmpty ? allItems : allItems.filter { item in
            item.name.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOption {
        case .name:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .date:
            return filtered.sorted { $0.purchaseDate > $1.purchaseDate }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.primaryGradient
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                Group {
                    if dataManager.items.isEmpty {
                        EmptyStateView(
                            icon: "list.bullet",
                            title: "Catalog is empty",
                            message: "Add items to your collection to see them in the catalog"
                        )
                    } else if filteredAndSortedItems.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "Nothing found",
                            message: "Try changing your search query"
                        )
                    } else {
                        List {
                            ForEach(Array(filteredAndSortedItems.enumerated()), id: \.element.id) { index, item in
                                NavigationLink(destination: ItemDetailView(item: item)) {
                                    CatalogItemRow(item: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .animatedCard()
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Catalog")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search by name")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(ThemeManager.accentTeal)
                    }
                }
            }
        }
    }
}

struct CatalogItemRow: View {
    let item: Item
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipped()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 28))
                        .foregroundColor(ThemeManager.secondaryText)
                        .frame(width: 70, height: 70)
                        .background(ThemeManager.secondaryText.opacity(0.1))
                }
            }
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(ThemeManager.headlineFont)
                    .foregroundColor(ThemeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(item.category)
                    .font(ThemeManager.captionFont)
                    .foregroundColor(ThemeManager.secondaryText)
                    .lineLimit(1)
                
                HStack {
                    Text(item.purchaseDate, style: .date)
                        .font(ThemeManager.smallFont)
                        .foregroundColor(ThemeManager.secondaryText)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            Circle()
                .fill(item.condition.color)
                .frame(width: 14, height: 14)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .cardStyle()
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(ThemeManager.quickAnimation, value: isPressed)
        .onTapGesture {
            withAnimation(ThemeManager.quickAnimation) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(ThemeManager.quickAnimation) {
                    isPressed = false
                }
            }
        }
    }
}

#Preview {
    CatalogScreen()
}
