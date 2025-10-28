import Foundation
import SwiftUI

struct Item: Identifiable, Codable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var category: String
    var purchaseDate: Date
    var condition: ItemCondition
    var notes: String
    var imageData: Data?
    var isInWishlist: Bool = false
    var priority: WishlistPriority = .medium
    
    init(name: String, category: String, purchaseDate: Date, condition: ItemCondition, notes: String, imageData: Data? = nil, isInWishlist: Bool = false, priority: WishlistPriority = .medium) {
        self.name = name
        self.category = category
        self.purchaseDate = purchaseDate
        self.condition = condition
        self.notes = notes
        self.imageData = imageData
        self.isInWishlist = isInWishlist
        self.priority = priority
    }
}

enum WishlistPriority: String, CaseIterable, Codable, Equatable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

enum ItemCondition: String, CaseIterable, Codable, Equatable {
    case new = "New"
    case used = "Used"
    case rare = "Rare"
    
    var color: Color {
        switch self {
        case .new:
            return .green
        case .used:
            return .orange
        case .rare:
            return .purple
        }
    }
}

class ItemManager: ObservableObject {
    @Published var items: [Item] = []
    
    private let userDefaultsKey = "SavedItems"
    
    init() {
        loadItems()
    }
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
    }
    
    func updateItem(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            saveItems()
        }
    }
    
    func deleteItem(_ item: Item) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func getCollectionItems() -> [Item] {
        return items.filter { !$0.isInWishlist }
    }
    
    func getWishlistItems() -> [Item] {
        return items.filter { $0.isInWishlist }.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }
    
    func moveToCollection(_ item: Item) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isInWishlist = false
            items[index].purchaseDate = Date()
            saveItems()
        }
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Item].self, from: data) {
            items = decoded
        }
    }
}
