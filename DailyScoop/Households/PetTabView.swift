//
//  PetTabView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 3/4/23.
//

import SwiftUI

struct PetTabView: View {
    @ObservedObject var pet: Pet
    @State var showEditPetView: Bool = false
    @State private var shouldPresentAddEliminationView: Bool = false
    var body: some View {
        TabView {
            PetChartView(pet: pet)
                .tabItem {
                    Label("Metrics", systemImage: "chart.bar.xaxis")
                }
            EliminationCalendarView(pet: pet)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            PetDetailView(pet: pet, showEditPetView: $showEditPetView)
                .tabItem {
                    Label("Details", systemImage: "person.text.rectangle.fill")
                }
        }
        .sheet(isPresented: $shouldPresentAddEliminationView) {
            AddEliminationView(pet: pet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("\(pet.name ?? "Pet")")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shouldPresentAddEliminationView.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
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
