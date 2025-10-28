import Foundation
import SwiftUI

class AppDataManager: ObservableObject {
    @Published var items: [Item] = []
    
    private let userDefaultsKey = "MyCollectionHub_Items"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init() {
        loadItems()
    }
    
    
    func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }
        
        do {
            items = try decoder.decode([Item].self, from: data)
        } catch {
            items = []
        }
    }
    
    func saveItems() {
        do {
            let data = try encoder.encode(items)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    
    func addItem(_ item: Item) {
        items.append(item)
        saveItems()
        print("Added item: \(item.name)")
    }
    
    func updateItem(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        items[index] = item
        saveItems()
    }
    
    func deleteItem(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        let itemName = items[index].name
        items.remove(at: index)
        saveItems()
        print("Deleted item: \(itemName)")
    }
    
    func moveItemFromWishlist(_ item: Item) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        items[index].isInWishlist = false
        items[index].purchaseDate = Date()
        saveItems()
    }
    
    
    func getCollectionItems() -> [Item] {
        return items.filter { !$0.isInWishlist }
    }
    
    func getWishlistItems() -> [Item] {
        return items.filter { $0.isInWishlist }.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
    }
    
    func getUniqueCategoriesCount() -> Int {
        return Set(getCollectionItems().map { $0.category }).count
    }
    
    func getConditionStatistics() -> [ItemCondition: Int] {
        let collectionItems = getCollectionItems()
        let grouped = Dictionary(grouping: collectionItems, by: { $0.condition })
        return ItemCondition.allCases.reduce(into: [ItemCondition: Int]()) { result, condition in
            result[condition] = grouped[condition]?.count ?? 0
        }
    }
    
    func getMonthlyGrowthData() -> [MonthlyData] {
        let collectionItems = getCollectionItems()
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: collectionItems) { item in
            calendar.dateInterval(of: .month, for: item.purchaseDate)?.start ?? item.purchaseDate
        }
        
        let sortedKeys = grouped.keys.sorted()
        var cumulativeCount = 0
        
        return sortedKeys.map { date in
            cumulativeCount += grouped[date]?.count ?? 0
            return MonthlyData(
                month: date,
                count: cumulativeCount
            )
        }
    }
    
    func clearAllData() {
        items.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func exportDataAsJSON() -> String? {
        do {
            let data = try encoder.encode(items)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
    
    func importDataFromJSON(_ jsonString: String) -> Bool {
        guard let data = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            let importedItems = try decoder.decode([Item].self, from: data)
            items = importedItems
            saveItems()
            return true
        } catch {
            return false
        }
    }
}

extension AppDataManager {
    static let shared = AppDataManager()
}
