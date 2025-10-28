import SwiftUI
import UniformTypeIdentifiers

struct ProfileScreen: View {
    @EnvironmentObject var dataManager: AppDataManager
    @State private var userName: String = ""
    @State private var showingShareSheet = false
    @State private var exportData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("User Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            TextField("Your name", text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: userName) { newValue in
                                    saveUserName(newValue)
                                }
                            
                            if !userName.isEmpty {
                                HStack {
                                    Text("Hello, \(userName)! 👋")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Export Collection")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Button(action: exportCollection) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                Text("Export Collection")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("General Information")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        VStack(spacing: 12) {
                            StatisticRow(
                                icon: "square.grid.2x2",
                                title: "Items in Collection",
                                value: "\(dataManager.getCollectionItems().count)",
                                color: .blue
                            )
                            
                            StatisticRow(
                                icon: "star.fill",
                                title: "Items in Wish List",
                                value: "\(dataManager.getWishlistItems().count)",
                                color: .orange
                            )
                            
                            StatisticRow(
                                icon: "tag.fill",
                                title: "Unique Categories",
                                value: "\(dataManager.getUniqueCategoriesCount())",
                                color: .purple
                            )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .onAppear {
                loadUserName()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportData = exportData {
                    ShareSheet(activityItems: [exportData])
                }
            }
            .alert("Export", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    
    private func loadUserName() {
        userName = UserDefaults.standard.string(forKey: "UserName") ?? ""
    }
    
    private func saveUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "UserName")
    }
    
    private func exportCollection() {
        guard let jsonString = dataManager.exportDataAsJSON() else {
            alertMessage = "Error exporting data"
            showingAlert = true
            return
        }
        
        exportData = jsonString.data(using: .utf8)
        showingShareSheet = true
    }
}


struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProfileScreen()
        .environmentObject(AppDataManager.shared)
}
