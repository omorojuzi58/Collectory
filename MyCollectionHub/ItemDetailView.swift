import SwiftUI

struct ItemDetailView: View {
    let item: Item
    @EnvironmentObject var dataManager: AppDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                            .frame(maxHeight: 300)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(item.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(item.condition.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item.condition.color.opacity(0.2))
                            .foregroundColor(item.condition.color)
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Purchase Date:")
                            Spacer()
                            Text(item.purchaseDate, style: .date)
                        }
                    }
                    
                    Divider()
                    
                    if !item.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(item.notes)
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Edit") {
                        showingEditView = true
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        })
        .sheet(isPresented: $showingEditView) {
            EditItemView(item: item)
                .environmentObject(dataManager)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete \"\(item.name)\" from the collection? This action cannot be undone."),
                primaryButton: Alert.Button.destructive(Text("Delete")) {
                    dataManager.deleteItem(item)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: Alert.Button.cancel(Text("Cancel"))
            )
        }
    }
}

#Preview {
    let sampleItem = Item(
        name: "Rare Coin",
        category: "Numismatics",
        purchaseDate: Date(),
        condition: .rare,
        notes: "Very rare coin from 1924"
    )
    
    NavigationView {
        ItemDetailView(item: sampleItem)
            .environmentObject(AppDataManager.shared)
    }
}
