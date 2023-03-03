//
//  PetDetailView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI

struct PetDetailView: View {
    @ObservedObject var pet: Pet
    private let stack = CoreDataStack.shared
    @State var shouldPresentAddEliminationView: Bool = false
    @State var showEditPetView: Bool = false
    var body: some View {
                ScrollView {
        VStack(spacing: 12) {
            HStack {
                if let imageData = pet.picture, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(8)
                }
                VStack {
                    Text("\(Gender(rawValue: pet.gender)!.description)")
                    Text(calculateYearsOld(with: pet.birthday ?? Date()))
                        .padding(.bottom, 8)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            Section {
                EliminationCalendarView(pet: pet)
                    .padding(.horizontal, 8)
            } header: {
                HStack(alignment: .center) {
                    Spacer()
                    Text("Eliminations")
                        .font(.title)
                    Spacer()
                    Button {
                        shouldPresentAddEliminationView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $shouldPresentAddEliminationView) {
                        AddEliminationView(pet: pet)
                    }
                }
                .padding(.horizontal, 24)
            }
            
        }
        .sheet(isPresented: $showEditPetView, content: {
            EditPetView(pet: pet)
        })
        .navigationTitle("\(pet.name!)")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditPetView.toggle()
                } label: {
                    Text("Edit")
                }
                
            }
                    }
        }
    }
    
    private func calculateYearsOld(with birthday: Date) -> String {
        let ageComponents = Calendar.current.dateComponents([.year, .month], from: birthday, to: .now)
        if ageComponents.year! == 0 {
            return "\(ageComponents.month!) months old"
        } else {
            return "\(ageComponents.year!) years old"
        }
    }
}
//
//struct PetDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PetDetailView()
//    }
//}
