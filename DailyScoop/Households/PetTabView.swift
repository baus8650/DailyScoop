//
//  PetTabView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 3/4/23.
//

import SwiftUI
import WidgetKit

struct PetTabView: View {
    @ObservedObject var pet: Pet
    @State private var shouldPresentAddEliminationView: Bool = false
    @State private var shouldPresentAccidentView: Bool = false
    @State var selectedTab: Int = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            PetDetailView(pet: pet)
                .tabItem {
                    Label("Details", systemImage: "person.text.rectangle.fill")
                }
                .tag(0)
            
            EliminationCalendarView(pet: pet)
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(1)
            PetChartView(pet: pet)
                .tabItem {
                    Label("Metrics", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
        .onAppear {
            self.selectedTab = self.selectedTab
        }
        .onChange(of: selectedTab, perform: { newValue in
            print("NEW VALUE \(newValue)")
            self.selectedTab = newValue
        })
        .sheet(isPresented: $shouldPresentAddEliminationView) {
            AddEliminationView(pet: pet)
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $shouldPresentAccidentView) {
            ReportAccidentView(confirmation: .constant(false), pet: pet)
                .presentationDetents([.height(315)])
                .presentationDragIndicator(.visible)
        }
        .navigationTitle("\(pet.name ?? "Pet")")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        recordQuickPee(pet: pet)
                    } label: {
                        Text("Quick Pee")
                    }
                    Button {
                        recordQuickPoop(pet: pet)
                    } label: {
                        Text("Quick Poop")
                    }
                    Button {
                        shouldPresentAccidentView = true
                    } label: {
                        Text("Quick Accident")
                    }
                    Button {
                        shouldPresentAddEliminationView = true
                    } label: {
                        Text("Detailed Elimination")
                    }
                } label: {
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
    
    private func recordQuickPoop(pet: Pet) {
        var elimination = Elimination(context: CoreDataStack.shared.context)
        elimination.pet = pet
        elimination.type = 2
        elimination.time = Date()
        CoreDataStack.shared.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func recordQuickPee(pet: Pet) {
        var elimination = Elimination(context: CoreDataStack.shared.context)
        elimination.pet = pet
        elimination.type = 1
        elimination.time = Date()
        CoreDataStack.shared.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
