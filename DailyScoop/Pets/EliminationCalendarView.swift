//
//  EliminationCalendarView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import SwiftUI

struct EliminationCalendarView: View {
    @ObservedObject var pet: Pet
    @State private var dateSelected: DateComponents?
    @State private var shouldDisplayEliminations: Bool = false
    
    var stack = CoreDataStack.shared
    var body: some View {
        VStack(spacing: 0) {
            if !shouldDisplayEliminations {
                ScrollView {
                    CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture), pet: pet, dateSelected: $dateSelected, shouldDisplayEliminations: $shouldDisplayEliminations)
                        .padding(.horizontal, 8)
                        .padding(.bottom, 0)
                }
            } else {
                CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture), pet: pet, dateSelected: $dateSelected, shouldDisplayEliminations: $shouldDisplayEliminations)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 0)
                DaySpecificEliminationsView(pet: pet, dateSelected: $dateSelected)
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
}
