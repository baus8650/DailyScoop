//
//  ContentView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.birthday, order: .reverse)])
    var pets: FetchedResults<Pet>
    private let stack = CoreDataStack.shared
    
    @State var shouldPresentAddPetView: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(pets) { pet in
                    NavigationLink {
                        PetDetailView(pet: pet)
                    } label: {
                        HStack(spacing: 16) {
                            if let imageData = pet.picture, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                            Text(pet.name ?? "")
                                .font(.headline)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            stack.delete(pet)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Pets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        shouldPresentAddPetView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $shouldPresentAddPetView) {
//                        AddPetView()
                    }

                }
            }
            Text("Select an item")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
