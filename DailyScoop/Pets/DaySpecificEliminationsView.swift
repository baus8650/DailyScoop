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
    @Binding var dateSelected: DateComponents?
    @Binding var notesToShow: String?
    @State var isShowingEditEliminationView: Bool = false
    @FetchRequest var eliminations: FetchedResults<Elimination>
    @State private var eliminationToEdit: Elimination?
    @State private var eliminationToDelete: Elimination?
    @State var shouldShowDeleteAlert: Bool = false
    @State var nestedNote: String? = nil {
        didSet {
            nestedNote = notesToShow
        }
    }
    var stack = CoreDataStack.shared
    
    init(pet: Pet, dateSelected: Binding<DateComponents?>, notesToShow: Binding<String?>) {
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
        self._notesToShow = notesToShow
    }
    
    var body: some View {
        if let dateSelected {
            
            ZStack(alignment: .center) {
                VStack(alignment: .center, spacing: 4) {
                    Text("\(formatter(for: dateSelected.date!, with: false))")
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
                                //                            .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                //                                Button(role: .destructive) {
                                //                                    stack.delete(elimination)
                                //                                } label: {
                                //                                    Label("Delete", systemImage: "trash")
                                //                                }
                                //                            })
                                //                            .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                                //                                Button {
                                //                                    eliminationToEdit = elimination
                                //                                } label: {
                                //                                    Label("Edit", systemImage: "pencil")
                                //                                }
                                //                            })
                                
                            }
                        }
                        .listStyle(.plain)
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
