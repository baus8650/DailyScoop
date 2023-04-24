//
//  DaySpecificEliminationsView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import CoreData
import Foundation
import SwiftUI

struct DaySpecificEliminationsView: View {
    @ObservedObject var pet: Pet
    @Binding var dateSelected: DateComponents?
    @State var isShowingEditEliminationView: Bool = false
    @FetchRequest var eliminations: FetchedResults<Elimination>
    @State private var eliminationToEdit: Elimination?
    var stack = CoreDataStack.shared
    
    init(pet: Pet, dateSelected: Binding<DateComponents?>) {
        self.pet = pet
        
        let selectedDate = Calendar.current.date(from: dateSelected.wrappedValue!)!
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.second = -1
        
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: dateComponents, to: startOfDay)
        
        let datePredicate = NSPredicate(format: "time >= %@ && time <= %@", startOfDay as CVarArg, endOfDay! as CVarArg)
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, petPredicate])
        
        _eliminations = FetchRequest(
            entity: Elimination.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Elimination.time, ascending: false)
            ],
            predicate: predicate
        )
        self._dateSelected = dateSelected
    }
    
    var body: some View {
        if let dateSelected {
            VStack(alignment: .center, spacing: 4) {
                Text("\(formatter(for: dateSelected.date!, with: false))")
                    .font(.title2)
                    .fontWeight(.medium)
                VStack(alignment: .leading) {
                    List(eliminations) { elimination in
                        EliminationCellView(elimination: elimination)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button(role: .destructive) {
                                    stack.delete(elimination)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            })
                            .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                                Button {
                                    eliminationToEdit = elimination
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                            })
                            .sheet(item: $eliminationToEdit) { elimination in
                                EditEliminationView(pet: pet, elimination: elimination)
                            }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    private func formatter(for date: Date, with timeShowing: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if timeShowing {
            formatter.timeStyle = .short
        } else {
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: date)
    }
    
    private func editDate(for date: Date, distance by: Int) -> String {
        var dateComponent = DateComponents()
        dateComponent.day = by
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: newDate!)
    }
    
    private func changeDate(from date: Date, byMoving day: Int) -> DateComponents {
        var dateComponent = DateComponents()
        dateComponent.day = day
        let newDate = Calendar.current.date(byAdding: dateComponent, to: date)
        
        var newDateComponents = DateComponents()
        newDateComponents.year = Calendar.current.component(.year, from: newDate!)
        newDateComponents.month = Calendar.current.component(.month, from: newDate!)
        newDateComponents.day = Calendar.current.component(.day, from: newDate!)
        
        return newDateComponents
    }
}
