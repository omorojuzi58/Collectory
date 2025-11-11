import SwiftUI

struct EditItemView: View {
    let item: Item
    @EnvironmentObject var dataManager: AppDataManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedImage: UIImage?
    @State private var name: String
    @State private var category: String
    @State private var purchaseDate: Date
    @State private var selectedCondition: ItemCondition
    @State private var notes: String
    @State private var showingImagePicker = false
    
    init(item: Item) {
        self.item = item
        
        _name = State(initialValue: item.name)
        _category = State(initialValue: item.category)
        _purchaseDate = State(initialValue: item.purchaseDate)
        _selectedCondition = State(initialValue: item.condition)
        _notes = State(initialValue: item.notes)
        
        if let imageData = item.imageData {
            _selectedImage = State(initialValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipped()
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                    .frame(width: 60, height: 60)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Text(selectedImage == nil ? "Select photo" : "Change photo")
                                .foregroundColor(.blue)
                            
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                }
                
                Section(header: Text("Condition")) {
                    Picker("Condition", selection: $selectedCondition) {
                        ForEach(ItemCondition.allCases, id: \.self) { condition in
                            Text(condition.rawValue).tag(condition)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty || category.isEmpty)
                }
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveChanges() {
        var updatedItem = item
        updatedItem.name = name
        updatedItem.category = category
        updatedItem.purchaseDate = purchaseDate
        updatedItem.condition = selectedCondition
        updatedItem.notes = notes
        updatedItem.imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        dataManager.updateItem(updatedItem)
        presentationMode.wrappedValue.dismiss()
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
    
    EditItemView(item: sampleItem)
        .environmentObject(AppDataManager.shared)
}
