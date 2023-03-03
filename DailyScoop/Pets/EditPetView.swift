//
//  EditPetview.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import SwiftUI

struct EditPetView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var pet: Pet
    @State var name: String = ""
    @State var gender: Gender = .female
    @State var birthday: Date = Date()
    @State var weight: String = ""
    @State var inputImage: UIImage?
    @State var image: Image?
    @State var showingImagePicker = false
    
    init(pet: Pet) {
        self.pet = pet
        self._name = State(initialValue: pet.name!)
        self._gender = State(initialValue: Gender(rawValue: pet.gender)!)
        self._birthday = State(initialValue: pet.birthday!)
        self._weight = State(initialValue: String(pet.weight))
        if let imageData = pet.picture {
            self._inputImage = State(initialValue: UIImage(data: imageData))
            if let image = inputImage {
                self._image = State(initialValue: Image(uiImage: image))
            }
        }
    }
    
    private let stack = CoreDataStack.shared
    
    var body: some View {
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
                .onTapGesture {
                    self.showingImagePicker = true
                }
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
        .scrollDismissesKeyboard(.immediately)            
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    private func savePet() {
        pet.name = name
        pet.birthday = birthday
        pet.gender = gender.rawValue
        if let petWeight = Double(weight) {
            pet.weight = petWeight
        } else {
            pet.weight = 0.0
        }
        let imageData = inputImage?.jpegData(compressionQuality: 1.0)
        pet.picture = imageData
        stack.save()
    }
}

