import SwiftUI

struct WishListScreen: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var showingAddItem = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.primaryGradient
                    .opacity(0.1)
                    .ignoresSafeArea()
                
                wishlistContent
            }
            .navigationTitle("Wish List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    GradientButton(title: "", icon: "plus") {
                        showingAddItem = true
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddWishlistItemView()
                    .environmentObject(dataManager)
            }
        }
    }
    
    @ViewBuilder
    private var wishlistContent: some View {
        if dataManager.getWishlistItems().isEmpty {
            EmptyStateView(
                icon: "star.fill",
                title: "Wish List is empty",
                message: "Add items you want to purchase"
            )
        } else {
            wishlistList
        }
    }
    
    private var wishlistList: some View {
        List {
            ForEach(Array(dataManager.getWishlistItems().enumerated()), id: \.element.id) { index, item in
                WishlistItemRow(item: item)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .animatedCard()
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
    }
    
    private func deleteItems(offsets: IndexSet) {
        let wishlistItems = dataManager.getWishlistItems()
        for index in offsets {
            let item = wishlistItems[index]
            dataManager.deleteItem(item)
        }
    }
}

struct WishlistItemRow: View {
    let item: Item
    @EnvironmentObject var dataManager: AppDataManager
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
                HStack {
                    Text(item.name)
                        .font(ThemeManager.headlineFont)
                        .foregroundColor(ThemeManager.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Circle()
                        .fill(item.priority.color)
                        .frame(width: 14, height: 14)
                }
                
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(ThemeManager.captionFont)
                        .foregroundColor(ThemeManager.secondaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(ThemeManager.springAnimation) {
                    dataManager.moveItemFromWishlist(item)
                }
            }) {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(ThemeManager.accentTeal)
                    
                    Text("Purchased")
                        .font(ThemeManager.smallFont)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeManager.accentTeal)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .hoverEffect()
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
    WishListScreen()
}
