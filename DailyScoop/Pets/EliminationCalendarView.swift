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
    @State var notesToShow: String? = nil
    
    var stack = CoreDataStack.shared
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                CalendarView(interval: DateInterval(start: .distantPast, end: .distantFuture), pet: pet, dateSelected: $dateSelected, shouldDisplayEliminations: $shouldDisplayEliminations)
                    .tint(Color("mainColor"))
                    .padding(.horizontal, 8)
                    .padding(.bottom, 0)
                if shouldDisplayEliminations {
                    DaySpecificEliminationsView(pet: pet, dateSelected: $dateSelected, notesToShow: $notesToShow)
                        .padding(.top, -16)
                    
                }
                Spacer()
            }
            if let notesToShow {
                Color.gray.opacity(0.01)
                    .ignoresSafeArea(.all)
                    .background(.ultraThinMaterial)
                NotesView(notes: $notesToShow)
                    .frame(width: 270, height: 212)
            }
        }
        .background(Color("background"))
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
