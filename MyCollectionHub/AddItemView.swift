import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: AppDataManager
    
    @State private var selectedImage: UIImage?
    @State private var name = ""
    @State private var category = ""
    @State private var purchaseDate = Date()
    @State private var selectedCondition = ItemCondition.new
    @State private var notes = ""
    @State private var showingImagePicker = false
    
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
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(name.isEmpty || category.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(
            name: name,
            category: category,
            purchaseDate: purchaseDate,
            condition: selectedCondition,
            notes: notes,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8)
        )
        
        dataManager.addItem(newItem)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddItemView()
        .environmentObject(AppDataManager.shared)
}
