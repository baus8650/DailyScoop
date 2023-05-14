//
//  EliminationHistoryCalendarView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/14/23.
//

import CoreData
import SwiftUI

struct EliminationHistoryCalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var todaysDate: Date = Date()
    @State var days: [CalendarDay] = (1...49).map { CalendarDay(day: "\($0)") }
    @Binding var startOfMonth: Date
    @Binding var endOfMonth: Date
    @Binding var dateToShow: Date
    @State var tappedDate: DateComponents
    @FetchRequest var eliminations: FetchedResults<Elimination>
    
    init(pet: Pet, startOfMonth: Binding<Date>, endOfMonth: Binding<Date>, dateToShow: Binding<Date>) {
        _startOfMonth = startOfMonth
        _endOfMonth = endOfMonth
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        
        var calendar = Calendar.current
////        calendar.timeZone = TimeZone(identifier: "UTC")!
////        let startOfMonth = s?
//        let endDC = DateComponents(month: 1, second: -1)
//        let endOfMonth = calendar.date(byAdding: endDC, to: startOfMonth)!
        
        let startPredicate = NSPredicate(format: "time >= %@", startOfMonth.wrappedValue as CVarArg)
        
        let endPredicate = NSPredicate(format: "time <= %@", endOfMonth.wrappedValue as CVarArg)
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [startPredicate, endPredicate, petPredicate])
        print("HERE ARE THE DATES \(startOfMonth) and end \(endOfMonth)")
        _eliminations = FetchRequest(entity: Elimination.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Elimination.time, ascending: true)], predicate: predicate)
        _dateToShow = dateToShow
        _tappedDate = State(initialValue: calendar.dateComponents([.day], from: Date()))
    }
    
    var body: some View {
        VStack {
//            HStack {
//                Text(extractMonthAndYear(from: startOfMonth))
//                    .foregroundColor(Color("mainColor"))
//                    .fontWeight(.medium)
//                Spacer()
//                HStack(spacing: 24) {
//                    Button {
//                        moveMonth(from: startOfMonth, by: -1)
//                        
//                    } label: {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(Color("mainColor"))
//                    }
//                    
//                    Button {
//                        moveMonth(from: startOfMonth, by: 1)
//                    } label: {
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(Color("mainColor"))
//                    }
//                }
//                .foregroundColor(.gray)
//            }
//            .padding(.bottom, 12)
            EliminationHistoryGridView(days: $days, startOfMonth: self.startOfMonth, endOfMonth: self.endOfMonth, tappedDate: $tappedDate)
            .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .onAppear {
            self.days = createCalendar(for: startOfMonth)
        }
        .onChange(of: eliminations.count) { newValue in
            self.days = createCalendar(for: startOfMonth)
        }
        .onChange(of: startOfMonth, perform: { newValue in
            print("HERE IS NEW VALUE \(newValue)")
            self.days = createCalendar(for: newValue)
        })
        .onChange(of: tappedDate) { newValue in
            var calendar = Calendar.current
//            calendar.timeZone = TimeZone(identifier: "UTC")!
            
            let knownDC = calendar.dateComponents([.month, .year], from: startOfMonth)
            var dateComponents = DateComponents()
//            dateComponents.timeZone = TimeZone(identifier: "UTC")!
            dateComponents.year = knownDC.year
            dateComponents.month = knownDC.month
            dateComponents.day = newValue.day
            
            self.dateToShow = calendar.date(from: dateComponents)!
        }
//        .onReceive(challenge.$progress) { _ in
//            self.days = createCalendar(for: Date())
//        }
    }
    
    func moveMonth(from date: Date, by distance: Int) {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var newDate = DateComponents()
        newDate.month = distance
        let calculatedDate = calendar.date(byAdding: newDate, to: date)!
        self.startOfMonth = calculatedDate
        var end = DateComponents(month: 1, second: -1)
        self.endOfMonth = calendar.date(byAdding: end, to: startOfMonth)!
        self.days = createCalendar(for: calculatedDate)
        print("IN MOVE, HERE IS END \(endOfMonth)")
    }
    
    func extractMonthAndYear(from date: Date) -> String {
        let formatter = DateFormatter()
//        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func createCalendar(for date: Date) -> [CalendarDay] {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let inputDate = calendar.dateComponents([.month, .year], from: date)
        
        var dayOne = DateComponents()
        dayOne.day = 1
        dayOne.month = inputDate.month
        dayOne.year = inputDate.year
        
        return populateDaysInCalendar(with: dayOne)
    }
    
    func populateDaysInCalendar(with startingDay: DateComponents) -> [CalendarDay] {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let today = calendar.dateComponents([.month], from: Date())
        let dateFromDayOne = calendar.date(from: startingDay)
        let numberOfDays = calendar.range(of: .day, in: .month, for: dateFromDayOne ?? Date())
        let startingDayWeekday = calendar.dateComponents([.weekday], from: dateFromDayOne ?? Date())
        
        let daysInPreviousMonth = createDaysInPreviousMonth(from: dateFromDayOne ?? Date(), with: startingDayWeekday)
        var daysInCurrentMonth: [CalendarDay]
        if startingDay.month == today.month {
            daysInCurrentMonth = createMonth(with: numberOfDays!.count, isInMonth: true, isInCurrentMonth: true)
        } else {
            daysInCurrentMonth = createMonth(with: numberOfDays!.count, isInMonth: true)
        }
        daysInCurrentMonth = update(calendar: daysInCurrentMonth, with: eliminations)
        let daysInNextMonth = createMonth(with: 14, isInMonth: false)
        
        var month = [CalendarDay]()
        
        month += [
            CalendarDay(day: "Sun", isInMonth: true),
            CalendarDay(day: "Mon", isInMonth: true),
            CalendarDay(day: "Tue", isInMonth: true),
            CalendarDay(day: "Wed", isInMonth: true),
            CalendarDay(day: "Thu", isInMonth: true),
            CalendarDay(day: "Fri", isInMonth: true),
            CalendarDay(day: "Sat", isInMonth: true)
        ]
        
        /// Reverse to count backwards from last day of previous month
        if !daysInPreviousMonth.isEmpty {
            month += daysInPreviousMonth.reversed()
        }
        
        month += daysInCurrentMonth
        month += daysInNextMonth
        month = Array(month[0..<49])
        
        /// Extract last row to determine if we can hide it or not to save space
        month = analyzeLastRow(from: month)
        
        return month
    }
    
    func analyzeLastRow(from fullMonth: [CalendarDay]) -> [CalendarDay] {
        /// Extract last row to determine if we can hide it or not to save space
        var month = fullMonth
        let lastRow = Array(month[42..<49])
        
        var isLastRowInCurrentMonth: Bool = true
        for day in lastRow {
            if day.isInMonth {
                isLastRowInCurrentMonth = false
            }
        }
        
        if isLastRowInCurrentMonth {
            month = Array(month[0..<42])
        } else {
            month = Array(month[0..<49])
        }
        
        return month
    }
    
    func createDaysInPreviousMonth(from date: Date, with startingDay: DateComponents) -> [CalendarDay] {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var dateComponents = DateComponents()
        dateComponents.month = -1
        let previousMonth = calendar.date(byAdding: dateComponents, to: date)
        
        let dayRange = calendar.range(of: .day, in: .month, for: previousMonth!)
        let numberOfDaysCount = dayRange!.count
        var previousMonthDays = [CalendarDay]()
        
        /// `DateComponents.weekday` considers `Sunday` as 1 so to display the week starting on Monday, we need to subtract two from this number:
        /// If the month started on a Wednesday, `startingDay.weekday!` will return 4 so to achieve the Monday starting point, we need to reduce the `.weekday` index by two because `DateComponents.weekday` of Monday is 2
        let startDayIndex = startingDay.weekday! - 1
        
        /// To avoid an index out of range error
        if startDayIndex > 0 {
            for i in 0..<(startingDay.weekday! - 1) {
                previousMonthDays.append(
                    CalendarDay(day: "\(numberOfDaysCount - i)", isInMonth: false)
                )
            }
        }
        
        return previousMonthDays
    }
    
    func createMonth(with range: Int, isInMonth: Bool, isInCurrentMonth: Bool = false) -> [CalendarDay] {
        var month = [CalendarDay]()
        for i in 1...range {
            month.append(
                CalendarDay(day: "\(i)", isInMonth: isInMonth, isInCurrentMonth: isInCurrentMonth)
            )
        }
        
        return month
    }
    
    func update(calendar days: [CalendarDay], with eliminations: FetchedResults<Elimination>) -> [CalendarDay] {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        var newDays = days
        for eliminationIndex in 0..<eliminations.count {
            let compareDC = calendar.dateComponents([.day], from: eliminations[eliminationIndex].time!)
            if let newDayIndex = newDays.firstIndex(where: { day in
                Int(day.day) == compareDC.day
            }) {
                newDays[newDayIndex].hasElimination = true
            }
        }
        return newDays
    }
    
    
    func filterEliminationsByMonth(eliminations: FetchedResults<Elimination>) -> [Elimination] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startOfDay = calendar.startOfDay(for: startOfMonth)
        var end = DateComponents(month: 1, second: -1)
        let endDate = calendar.date(byAdding: end, to: startOfMonth)
        let startOfEnd = calendar.startOfDay(for: endDate!)
        print("HERE IS THE END IN FILTER", startOfEnd)
        return eliminations.filter {
            $0.time! >= startOfDay && $0.time! <= startOfEnd
        }
    }
}

//struct EliminationHistoryCalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        EliminationHistoryCalendarView(pet: CoreDataStack.preview.persistentContainer.viewContext)
//    }
//}

struct CalendarDay: Identifiable {
    let id: UUID = UUID()
    var day: String
    var hasElimination: Bool = false
    var isInMonth: Bool = false
    var isInCurrentMonth: Bool = false
}
