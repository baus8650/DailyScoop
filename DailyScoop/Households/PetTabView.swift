//
//  PetTabView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 3/4/23.
//

import SwiftUI

struct PetTabView: View {
    @ObservedObject var pet: Pet
    @State private var shouldPresentAddEliminationView: Bool = false

    var body: some View {
        TabView {
            PetDetailView(pet: pet)
                .tabItem {
                    Label("Details", systemImage: "person.text.rectangle.fill")
                }
            
            EliminationCalendarView(pet: pet)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
            
            PetChartView(pet: pet)
                .tabItem {
                    Label("Metrics", systemImage: "chart.bar.xaxis")
                }
            
        }
        .sheet(isPresented: $shouldPresentAddEliminationView) {
            AddEliminationView(pet: pet)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("\(pet.name ?? "Pet")")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shouldPresentAddEliminationView.toggle()
                } label: {
                    Image("hydrant")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                }
            }
        }
    }
}
