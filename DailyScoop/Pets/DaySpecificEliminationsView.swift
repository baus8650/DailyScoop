//
//  DaySpecificEliminationsView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import CoreData
import Foundation
import SwiftUI
import WidgetKit

struct DaySpecificEliminationsView: View {
    @ObservedObject var pet: Pet
    @Binding var dateSelected: Date
    @Binding var notesToShow: String?
    @State var isShowingEditEliminationView: Bool = false
    @FetchRequest var eliminations: FetchedResults<Elimination>
    @State private var eliminationToEdit: Elimination?
    @State private var eliminationToDelete: Elimination?
    //    @State var eliminations: [Elimination] = []
    @State var shouldShowDeleteAlert: Bool = false
    @State var nestedNote: String? = nil {
        didSet {
            nestedNote = notesToShow
        }
    }
    var stack = CoreDataStack.shared
    
    init(pet: Pet, dateSelected: Binding<Date>, notesToShow: Binding<String?>) {
        self.pet = pet
        _dateSelected = dateSelected
        _notesToShow = notesToShow
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startOfDay = calendar.startOfDay(for: dateSelected.wrappedValue)
        var endDC = DateComponents(day: 1, second: -1)
//        endDC.timeZone = TimeZone(identifier: "UTC")!
        let endOfDay = calendar.date(byAdding: endDC, to: startOfDay)!
        
        let startPredicate = NSPredicate(format: "time >= %@", startOfDay as CVarArg)
        
        let endPredicate = NSPredicate(format: "time <= %@", endOfDay as CVarArg)
        
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [startPredicate, endPredicate, petPredicate])
        _eliminations = FetchRequest(entity: Elimination.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Elimination.time, ascending: true)], predicate: predicate)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color("background")
                .ignoresSafeArea()
            if eliminations.count > 0 {
                VStack(alignment: .center, spacing: 4) {
                    Text("\(formatter(for: dateSelected, with: false))")
                        .font(.title2)
                        .foregroundColor(Color("mainColor"))
                        .fontWeight(.medium)
                    VStack(alignment: .leading) {
                        List {
                            ForEach(eliminations) { elimination in
                                HStack {
                                    EliminationCellView(elimination: elimination)
                                    Spacer()
                                    HStack(spacing: 8) {
                                        if elimination.notes != nil && elimination.notes != "" {
                                            Button {
                                                notesToShow = elimination.notes!
                                            } label: {
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color("buttonBackground"))
                                                    .frame(width: 38, height: 38)
                                                    .overlay(
                                                        Image(systemName: "list.clipboard.fill")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .foregroundColor(Color("mainColor"))
                                                            .padding(8)
                                                        
                                                    )
                                            }
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(Color("mainColor")).opacity(0.5)
                                                .frame(width: 1, height: 40)
                                        }
                                        Button {
                                            eliminationToEdit = elimination
                                        } label: {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color("buttonBackground"))
                                                .frame(width: 38, height: 38)
                                                .overlay(
                                                    Image(systemName: "pencil")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(Color("mainColor"))
                                                        .padding(8)
                                                    
                                                )
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(Color("mainColor")).opacity(0.5)
                                            .frame(width: 1, height: 40)
                                        Button {
                                            eliminationToDelete = elimination
                                            shouldShowDeleteAlert = true
                                        } label: {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color("buttonBackground"))
                                                .frame(width: 38, height: 38)
                                                .overlay(
                                                    Image(systemName: "trash.fill")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .foregroundColor(Color("accidentColor"))
                                                        .padding(8)
                                                    
                                                )
                                            
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            } else {
                VStack {
                    Text("No elimination data recorded for today!")
                        .foregroundColor(Color("mainColor"))
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
            }
            
        }
        .alert("Delete Elimination?", isPresented: $shouldShowDeleteAlert, actions: {
            Button("Delete", role: .destructive) {
                if let elimination = eliminationToDelete {
                    stack.delete(elimination)
                    WidgetCenter.shared.reloadAllTimelines()
                }
                eliminationToDelete = nil
            }
        }, message: {
            Text("Are you sure you want to delete this elimination? This action is permanent and cannot be undone.")
        })
        .sheet(item: $eliminationToEdit) { elimination in
            EditEliminationView(pet: pet, elimination: elimination)
        }
        
    }
    
    private func formatter(for date: Date, with timeShowing: Bool = true) -> String {
        var formatter = DateFormatter()
//        formatter.timeZone = TimeZone(identifier: "UTC")!
        formatter.dateStyle = .medium
        if timeShowing {
            formatter.timeStyle = .short
        } else {
            formatter.timeStyle = .none
        }
        
        return formatter.string(from: date)
    }
    
    private func editDate(for date: Date, distance by: Int) -> String {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var dateComponent = DateComponents()
        dateComponent.day = by
        let newDate = calendar.date(byAdding: dateComponent, to: date)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        
        return formatter.string(from: newDate!)
    }
    
    private func changeDate(from date: Date, byMoving day: Int) -> DateComponents {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var dateComponent = DateComponents()
//        dateComponent.timeZone = TimeZone(identifier: "UTC")!
        dateComponent.day = day
        let newDate = calendar.date(byAdding: dateComponent, to: date)
        
        var newDateComponents = DateComponents()
//        newDateComponents.timeZone = TimeZone(identifier: "UTC")!
        newDateComponents.year = calendar.component(.year, from: newDate!)
        newDateComponents.month = calendar.component(.month, from: newDate!)
        newDateComponents.day = calendar.component(.day, from: newDate!)
        
        return newDateComponents
    }
    
//    func filterEliminationsByDay(eliminations: FetchedResults<Elimination>) -> [Elimination] {
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
//        let startOfDay = calendar.startOfDay(for: dateToShow)
//        var end = DateComponents(day: 1, second: -1)
//        let endDate = calendar.date(byAdding: end, to: startOfDay)
//        //        let startOfEnd = calendar.startOfDay(for: endDate!)
//        let filteredEliminations =  eliminations.filter {
//            $0.time! >= startOfDay && $0.time! <= endDate!
//        }
//        print("FILTERED ",filteredEliminations)
//        return filteredEliminations
//    }
}
