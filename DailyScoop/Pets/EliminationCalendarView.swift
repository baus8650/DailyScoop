//
//  EliminationCalendarView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/12/23.
//

import SwiftUI

struct EliminationCalendarView: View {
    @ObservedObject var pet: Pet
//    @State private var dateSelected: DateComponents?
    @State private var shouldDisplayEliminations: Bool = false
    @State var notesToShow: String? = nil
    @State var startOfMonth: Date
    @State var endOfMonth: Date
    @State var dateToShow: Date = Date() {
        didSet {
            print("WHAT IS HAPPENING \(dateToShow)")
        }
    }
    @State var updatedEliminations: [Elimination] = []
//    @FetchRequest var eliminations: FetchedResults<Elimination>
    
    init(pet: Pet) {
        self.pet = pet
        
        var calendar = Calendar.current
        //        calendar.timeZone = TimeZone(identifier: "UTC")!
        let somDC = calendar.dateComponents([.month, .year], from: Date())
        let start = DateComponents(year: somDC.year, month: somDC.month, day: 1)
        var end: DateComponents
        if start.month == 12 {
            end = DateComponents(year: somDC.year, month: 12, day: 31)
        } else {
            end = DateComponents(year: somDC.year, month: somDC.month! + 1, day: -1)
        }
        print("START \(calendar.date(from: start)!)")
        _startOfMonth = State(initialValue: calendar.date(from: start)!)
        _endOfMonth = State(initialValue: calendar.date(from: end)!)
//        _eliminations = FetchRequest(entity: Elimination.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Elimination.time, ascending: true)], predicate: NSPredicate(format: "pet == %@", pet))
    }
    
    var stack = CoreDataStack.shared
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 8) {
                HStack {
                    Text(extractMonthAndYear(from: startOfMonth))
                        .foregroundColor(Color("mainColor"))
                        .fontWeight(.bold)
                    Spacer()
                    HStack(spacing: 24) {
                        Button {
                            self.startOfMonth = moveMonth(from: startOfMonth, by: -1).0
                            
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("mainColor"))
                        }
                        
                        Button {
                            self.endOfMonth = moveMonth(from: startOfMonth, by: 1).1
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color("mainColor"))
                        }
                    }
                    .foregroundColor(.gray)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                EliminationHistoryCalendarView(pet: pet, startOfMonth: $startOfMonth, endOfMonth: $endOfMonth, dateToShow: $dateToShow)
                DaySpecificEliminationsView(pet: pet, dateSelected: $dateToShow, notesToShow: $notesToShow)
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
    
    func extractMonthAndYear(from date: Date) -> String {
        let formatter = DateFormatter()
        //        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
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
    
    func findStartOfMonth() -> Date {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let somDC = calendar.dateComponents([.month, .year], from: Date())
        let start = DateComponents(year: somDC.year, month: somDC.month, day: 1)
        var end: DateComponents
        if start.month == 12 {
            end = DateComponents(year: somDC.year, month: 12, day: 31)
        } else {
            end = DateComponents(year: somDC.year, month: somDC.month! + 1, day: -1)
        }
        print("START \(calendar.date(from: start)!)")
        return calendar.date(from: start)!
    }
    
    func findEndOfMonth() -> Date {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let somDC = calendar.dateComponents([.month, .year], from: Date())
        let start = DateComponents(year: somDC.year, month: somDC.month, day: 1)
        var end: DateComponents
        if start.month == 12 {
            end = DateComponents(year: somDC.year, month: 12, day: 31)
        } else {
            end = DateComponents(year: somDC.year, month: somDC.month! + 1, day: -1)
        }
        print("END \(calendar.date(from: end)!)")
        return calendar.date(from: end)!
    }
    
    func filterEliminationsByDay(eliminations: FetchedResults<Elimination>) -> [Elimination] {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startOfDay = calendar.startOfDay(for: dateToShow)
        var end = DateComponents(day: 1, second: -1)
        let endDate = calendar.date(byAdding: end, to: startOfDay)
//        let startOfEnd = calendar.startOfDay(for: endDate!)
        let filteredEliminations =  eliminations.filter {
            $0.time! >= startOfDay && $0.time! <= endDate!
        }
        print("FILTERED ",filteredEliminations)
        return filteredEliminations
    }
    
    func moveMonth(from date: Date, by distance: Int) -> (Date, Date) {
        var calendar = Calendar.current
        //        calendar.timeZone = TimeZone(identifier: "UTC")!
        var newDate = DateComponents()
        newDate.month = distance
        let calculatedDate = calendar.date(byAdding: newDate, to: date)!
        self.startOfMonth = calculatedDate
        var end = DateComponents(month: 1, second: -1)
        self.endOfMonth = calendar.date(byAdding: end, to: startOfMonth)!
        return (startOfMonth, endOfMonth)
    }
    
//    func createCalendar(for date: Date) -> [CalendarDay] {
//        var calendar = Calendar.current
//        //        calendar.timeZone = TimeZone(identifier: "UTC")!
//        let inputDate = calendar.dateComponents([.month, .year], from: date)
//
//        var dayOne = DateComponents()
//        dayOne.day = 1
//        dayOne.month = inputDate.month
//        dayOne.year = inputDate.year
//
//        return populateDaysInCalendar(with: dayOne)
//    }
    
//    func populateDaysInCalendar(with startingDay: DateComponents) -> [CalendarDay] {
//        var calendar = Calendar.current
//        //        calendar.timeZone = TimeZone(identifier: "UTC")!
//        let today = calendar.dateComponents([.month], from: Date())
//        let dateFromDayOne = calendar.date(from: startingDay)
//        let numberOfDays = calendar.range(of: .day, in: .month, for: dateFromDayOne ?? Date())
//        let startingDayWeekday = calendar.dateComponents([.weekday], from: dateFromDayOne ?? Date())
//
//        let daysInPreviousMonth = createDaysInPreviousMonth(from: dateFromDayOne ?? Date(), with: startingDayWeekday)
//        var daysInCurrentMonth: [CalendarDay]
//        if startingDay.month == today.month {
//            daysInCurrentMonth = createMonth(with: numberOfDays!.count, isInMonth: true, isInCurrentMonth: true)
//        } else {
//            daysInCurrentMonth = createMonth(with: numberOfDays!.count, isInMonth: true)
//        }
//        daysInCurrentMonth = update(calendar: daysInCurrentMonth, with: eliminations)
//        let daysInNextMonth = createMonth(with: 14, isInMonth: false)
//
//        var month = [CalendarDay]()
//
//        month += [
//            CalendarDay(day: "Sun", isInMonth: true),
//            CalendarDay(day: "Mon", isInMonth: true),
//            CalendarDay(day: "Tue", isInMonth: true),
//            CalendarDay(day: "Wed", isInMonth: true),
//            CalendarDay(day: "Thu", isInMonth: true),
//            CalendarDay(day: "Fri", isInMonth: true),
//            CalendarDay(day: "Sat", isInMonth: true)
//        ]
//
//        /// Reverse to count backwards from last day of previous month
//        if !daysInPreviousMonth.isEmpty {
//            month += daysInPreviousMonth.reversed()
//        }
//
//        month += daysInCurrentMonth
//        month += daysInNextMonth
//        month = Array(month[0..<49])
//
//        /// Extract last row to determine if we can hide it or not to save space
//        month = analyzeLastRow(from: month)
//
//        return month
//    }
//
//    func analyzeLastRow(from fullMonth: [CalendarDay]) -> [CalendarDay] {
//        /// Extract last row to determine if we can hide it or not to save space
//        var month = fullMonth
//        let lastRow = Array(month[42..<49])
//
//        var isLastRowInCurrentMonth: Bool = true
//        for day in lastRow {
//            if day.isInMonth {
//                isLastRowInCurrentMonth = false
//            }
//        }
//
//        if isLastRowInCurrentMonth {
//            month = Array(month[0..<42])
//        } else {
//            month = Array(month[0..<49])
//        }
//
//        return month
//    }
//
//    func createDaysInPreviousMonth(from date: Date, with startingDay: DateComponents) -> [CalendarDay] {
//        var calendar = Calendar.current
//        //        calendar.timeZone = TimeZone(identifier: "UTC")!
//        var dateComponents = DateComponents()
//        dateComponents.month = -1
//        let previousMonth = calendar.date(byAdding: dateComponents, to: date)
//
//        let dayRange = calendar.range(of: .day, in: .month, for: previousMonth!)
//        let numberOfDaysCount = dayRange!.count
//        var previousMonthDays = [CalendarDay]()
//
//        /// `DateComponents.weekday` considers `Sunday` as 1 so to display the week starting on Monday, we need to subtract two from this number:
//        /// If the month started on a Wednesday, `startingDay.weekday!` will return 4 so to achieve the Monday starting point, we need to reduce the `.weekday` index by two because `DateComponents.weekday` of Monday is 2
//        let startDayIndex = startingDay.weekday! - 1
//
//        /// To avoid an index out of range error
//        if startDayIndex > 0 {
//            for i in 0..<(startingDay.weekday! - 1) {
//                previousMonthDays.append(
//                    CalendarDay(day: "\(numberOfDaysCount - i)", isInMonth: false)
//                )
//            }
//        }
//
//        return previousMonthDays
//    }
//
//    func createMonth(with range: Int, isInMonth: Bool, isInCurrentMonth: Bool = false) -> [CalendarDay] {
//        var month = [CalendarDay]()
//        for i in 1...range {
//            month.append(
//                CalendarDay(day: "\(i)", isInMonth: isInMonth, isInCurrentMonth: isInCurrentMonth)
//            )
//        }
//
//        return month
//    }
//
//    func update(calendar days: [CalendarDay], with eliminations: FetchedResults<Elimination>) -> [CalendarDay] {
//        var calendar = Calendar.current
//        //        calendar.timeZone = TimeZone(identifier: "UTC")!
//        var newDays = days
//        for eliminationIndex in 0..<eliminations.count {
//            let compareDC = calendar.dateComponents([.day], from: eliminations[eliminationIndex].time!)
//            if let newDayIndex = newDays.firstIndex(where: { day in
//                Int(day.day) == compareDC.day
//            }) {
//                newDays[newDayIndex].hasElimination = true
//            }
//        }
//        return newDays
//    }
    
//    func filterEliminationsByMonth(eliminations: FetchedResults<Elimination>) -> [Elimination] {
//        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
//        let startOfDay = calendar.startOfDay(for: startOfMonth)
//        var end = DateComponents(month: 1, second: -1)
//        let endDate = calendar.date(byAdding: end, to: startOfMonth)
//        let startOfEnd = calendar.startOfDay(for: endDate!)
//        print("HERE IS THE END IN FILTER", startOfEnd)
//        return eliminations.filter {
//            $0.time! >= startOfDay && $0.time! <= startOfEnd
//        }
//    }
}
