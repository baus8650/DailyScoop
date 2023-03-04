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
        //                ScrollView {
        VStack(spacing: 12) {
            Section {
                EliminationCalendarView(pet: pet)
//                    .padding(.horizontal, 8)
            } header: {
                HStack(alignment: .center) {
                    Text("Eliminations")
                        .font(.title)
                        .fontWeight(.bold)
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
//                .padding(.horizontal, 24)
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
        //        }
    }
}
//
//struct PetDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PetDetailView()
//    }
//}
