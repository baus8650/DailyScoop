//
//  EliminationHistoryGridView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/14/23.
//

import CoreData
import SwiftUI

struct EliminationHistoryGridView: View {
    @Binding var days: [CalendarDay]
    @Binding var tappedDate: DateComponents
    @FetchRequest var eliminations: FetchedResults<Elimination>
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(days: Binding<[CalendarDay]>, startOfMonth: Date, endOfMonth: Date, tappedDate: Binding<DateComponents>) {
        _days = days
        
        _tappedDate = tappedDate
        let startPredicate = NSPredicate(format: "time >= %@", startOfMonth as CVarArg)
        let endPredicate = NSPredicate(format: "time <= %@", endOfMonth as CVarArg)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [startPredicate, endPredicate])
        
        _eliminations = FetchRequest(entity: Elimination.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Elimination.time, ascending: true)], predicate: predicate)
    }
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(days) { day in
                if let numberDay = Int(day.day) {
                    Text("\(numberDay)")
                        .frame(width: 38, height: 38)
                        .foregroundColor(day.isInMonth ? (day.hasElimination ? Color("historyText") : .gray) : .gray.opacity(0.0))
                        .fontWeight(isDayToday(calendarDay: day) ? day.isInCurrentMonth ? .heavy : .regular : .regular)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(day.hasElimination ? Color("mainColor") : .clear)
                        )
                        .onTapGesture {
                            if day.hasElimination {
                                print("HERE IS DAY \(day.day)")
                                var dc = DateComponents()
//                                dc.timeZone = TimeZone(identifier: "UTC")!
                                dc.day = Int(day.day)
                                print("WHAT \(dc.day)")
                                self.tappedDate = dc
                                print("TAPPED \(tappedDate)")
                            }
                        }
                } else {
                    Text("\(day.day)")
                        .frame(width: 48, height: 16)
                        .foregroundColor(day.isInMonth ? .gray : .gray.opacity(0.4))
                }
            }
        }
    }
    
    func isDayToday(calendarDay: CalendarDay) -> Bool {
        /// Use `challenge.startDate` to extract the month and year to localize the comparison date appropriately
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var dc = calendar.dateComponents([.month, .year], from: Date())
        /// Add the `.day` component for the specific `calendarDay.day`
        dc.day = Int(calendarDay.day)
        /// Create a date component for each day so that it is set in the month of the current challenge for comparison
        let comparisonDate = calendar.date(from: dc)!
        return calendar.isDateInToday(comparisonDate) ?
        true : false
    }
}
//
//struct EliminationHistoryGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        EliminationHistoryGridView(startDate: Date(), endDate: Date(), eliminations: [], days: .constant([]))
//    }
//}
