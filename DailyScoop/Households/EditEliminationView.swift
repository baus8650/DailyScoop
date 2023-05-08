//
//  EditEliminationView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 3/2/23.
//

import CoreData
import SwiftUI
import WidgetKit

struct EditEliminationView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var pet: Pet
    @ObservedObject var elimination: Elimination
    @State var time: Date
    @State var type: EliminationType
    @State var consistency: Double
    @State var notes: String
    @State var wasAccident: Bool
    var stack = CoreDataStack.shared
    
    init(pet: Pet, elimination: Elimination) {
        self.pet = pet
        self.elimination = elimination
        self._time = State(wrappedValue: elimination.time ?? Date())
        self._type = State(wrappedValue: EliminationType(rawValue: elimination.type) ?? .none)
        self._consistency = State(wrappedValue:  Double(elimination.consistency))
        self._notes = State(wrappedValue:  elimination.notes ?? "")
        self._wasAccident = State(initialValue: elimination.wasAccident)
    }
    
    var body: some View {
        Form {
            DatePicker("Time", selection: $time)
            Picker("Type", selection: $type) {
                ForEach(EliminationType.allCases) { type in
                    Text(type.description)
                }
            }
            Toggle(isOn: $wasAccident) {
                Text("Was this an accident?")
            }
            if type == .solid {
                Slider(value: $consistency, in: 1...5, step: 1) {
                    Text("Consistency")
                } minimumValueLabel: {
                    Text("Liquid")
                } maximumValueLabel: {
                    Text("Solid")
                }
                .tint(.brown)
            }
            TextField("Additional notes:", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5, reservesSpace: true)
            HStack(spacing: 48) {
                Spacer()
                Button {
                    saveElimination(elimination: elimination)
                    WidgetCenter.shared.reloadAllTimelines()
                } label: {
                    Text("Save")
                }
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                }
                Spacer()
            }
        }
    }
    
    private func saveElimination(elimination: Elimination) {
        elimination.type = type.rawValue
        elimination.consistency = Int16(consistency)
        elimination.time = time
        elimination.notes = notes
        elimination.pet = pet
        elimination.wasAccident = wasAccident
        stack.save()
    }
}
