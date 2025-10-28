
import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = AppDataManager.shared
    
    var body: some View {
        TabView {
            CollectionScreen()
                .tabItem { 
                    Label("Collection", systemImage: "square.grid.2x2") 
                }
            
            CatalogScreen()
                .tabItem { 
                    Label("Catalog", systemImage: "list.bullet") 
                }
            
            StatisticsScreen()
                .tabItem { 
                    Label("Statistics", systemImage: "chart.pie.fill") 
                }
            
            WishListScreen()
                .tabItem { 
                    Label("Wish List", systemImage: "star.fill") 
                }
            
            ProfileScreen()
                .tabItem { 
                    Label("Profile", systemImage: "person.crop.circle") 
                }
        }
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
}
