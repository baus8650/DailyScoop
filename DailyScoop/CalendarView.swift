//
//  CalendarView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    let interval: DateInterval
    @ObservedObject var pet: Pet
    @Binding var dateSelected: DateComponents?
    @Binding var shouldDisplayEliminations: Bool
    func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        view.calendar = Calendar(identifier: .gregorian)
        view.availableDateRange = interval
        let dateSelection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        view.selectionBehavior = dateSelection
        return view
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, pet: pet)
    }
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        
        @ObservedObject var pet: Pet
        var parent: CalendarView
        init(parent: CalendarView, pet: Pet) {
            self.parent = parent
            self.pet = pet
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            parent.dateSelected = dateComponents
            guard let dateComponents else { return }
            if let foundEliminations = pet.eliminations?.allObjects as? [Elimination] {
                var filteredEliminations = foundEliminations.filter {
                    Calendar.current.isDate($0.time!, equalTo: dateComponents.date!, toGranularity: .day)
                }
                if !filteredEliminations.isEmpty {
                    parent.shouldDisplayEliminations = true
                }
            }
        }
        
    }
}
