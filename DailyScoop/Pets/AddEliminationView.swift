//
//  AddEliminationView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI
import WidgetKit

struct AddEliminationView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.dismiss) var dismiss
    @ObservedObject var pet: Pet
    @State var time: Date = Date()
    @State var type: EliminationType = .none
    @State var consistency: Double = 1
    @State var notes: String = ""
    @State var wasAccident: Bool = false
    @State var showEmptyTypeAlert: Bool = false
    var stack = CoreDataStack.shared
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("buttonBackground")
                .ignoresSafeArea()
            VStack(spacing: 8) {
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
            }
            .padding(.top, 28)
            .scrollDismissesKeyboard(.immediately)
                HStack(spacing: 48) {
                    Spacer()
                    Button {
                        if type != .none {
                            saveElimination()
                        } else {
                            showEmptyTypeAlert = true
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
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
                .padding(.bottom, 24)
            }
            Text("**Add Elimination**")
                .foregroundColor(Color("mainColor"))
                .padding(.top, 24)
        }
        .alert("No Type Selected", isPresented: $showEmptyTypeAlert) {
            Button {
                
            } label: {
                Text("Okay")
            }
        } message: {
            Text("Please select an elimination type or dismiss the view.")
        }

    }
    
    private func saveElimination() {
        withAnimation {
            let newElimination = Elimination(context: managedObjectContext)
            newElimination.type = type.rawValue
            newElimination.consistency = Int16(consistency)
            newElimination.time = time
            newElimination.notes = notes
            newElimination.pet = pet
            newElimination.wasAccident = wasAccident
            stack.save()
        }
    }
}


