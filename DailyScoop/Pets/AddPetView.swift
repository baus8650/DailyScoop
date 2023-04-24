//
//  AddPetView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI

struct AddPetView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var household: Household
    @State var name: String = ""
    @State var gender: Gender = .female
    @State var birthday: Date = Date()
    @State var weight: String = ""
    @State var inputImage: UIImage?
    @State var image: Image?
    @State var showingImagePicker = false
    
    private let stack = CoreDataStack.shared
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                DatePicker("Birthday", selection: $birthday, displayedComponents: [.date])
                    .datePickerStyle(.automatic)
                Picker("Gender", selection: $gender) {
                    ForEach(Gender.allCases) { gender in
                        Text(gender.description)
                            .tag(gender)
                    }
                }
                .pickerStyle(.segmented)
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                if image == nil {
                    Button {
                        self.showingImagePicker = true
                    } label: {
                        Text("Choose a photo")
                    }
                }
                image?
                    .resizable()
                    .scaledToFit()
                HStack(spacing: 48) {
                    Spacer()
                    Button {
                        savePet()
                    } label: {
                        Text("Save")
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: $inputImage)
            }
            .padding(.top, -30)
            .navigationTitle("Add Pet")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    private func savePet() {
        withAnimation {
            let newPet = Pet(context: managedObjectContext)
            newPet.name = name
            newPet.birthday = birthday
            newPet.gender = gender.rawValue
            if let petWeight = Double(weight) {
                newPet.weight = petWeight
            } else {
                newPet.weight = 0.0
            }
            let imageData = inputImage?.jpegData(compressionQuality: 1.0)
            newPet.picture = imageData
            newPet.household = household
            stack.save()
        }
    }
}
