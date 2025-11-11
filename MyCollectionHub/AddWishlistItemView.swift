import SwiftUI

struct AddWishlistItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dataManager: AppDataManager
    
    @State private var selectedImage: UIImage?
    @State private var name = ""
    @State private var notes = ""
    @State private var selectedPriority = WishlistPriority.medium
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
                
                Section(header: Text("Information")) {
                    TextField("Name", text: $name)
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(WishlistPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Add to Wish List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveItem()
                    }
                    .disabled(name.isEmpty)
                }
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private func saveItem() {
        let newItem = Item(
            name: name,
            category: "Wish List",
            purchaseDate: Date(),
            condition: .new,
            notes: notes,
            imageData: selectedImage?.jpegData(compressionQuality: 0.8),
            isInWishlist: true,
            priority: selectedPriority
        )
        
        dataManager.addItem(newItem)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddWishlistItemView()
        .environmentObject(AppDataManager.shared)
}
