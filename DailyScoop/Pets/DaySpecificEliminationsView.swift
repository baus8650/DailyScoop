//
//  DaySpecificEliminationsView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import Foundation
import SwiftUI

struct DaySpecificEliminationsView: View {
    @ObservedObject var pet: Pet
    @Binding var dateSelected: DateComponents?
    var stack = CoreDataStack.shared
    
    var body: some View {
        if let dateSelected {
            VStack(alignment: .center, spacing: 4) {
                Text("\(formatter(for: dateSelected.date!, with: false))")
                    .font(.title2)
                    .fontWeight(.medium)
                VStack(alignment: .leading) {
                    if let foundEliminations = pet.eliminations?.allObjects as? [Elimination] {
                        let sortedEliminations = foundEliminations.sorted {
                            $0.time! > $1.time!
                        }
                        let filteredEliminations = sortedEliminations.filter {
                            Calendar.current.isDate($0.time!, equalTo: dateSelected.date!, toGranularity: .day)
                        }
                        //                    List {
                        ForEach(filteredEliminations) { event in
                            EliminationCellView(elimination: event, typeInt: event.type, wasAccident: event.wasAccident)
                                .padding(.horizontal, 32)
                        }
                        
                        //                    .navigationBarTitle(formatter(for: dateSelected.date!, with: false))
                        //                    .navigationBarTitleDisplayMode(.large)
                        //                    .toolbar {
                        //                        ToolbarItem(placement: .navigationBarTrailing) {
                        //                            Button {
                        //
                        //
                        ////                                dateSelected = changeDate(from: dateSelected.date, byMoving: -1)
                        //                            } label: {
                        //                                Text("\(editDate(for: dateSelected.date!, distance: -1))")
                        //                            }
                        //                        }
                        //                    }
                    }
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
