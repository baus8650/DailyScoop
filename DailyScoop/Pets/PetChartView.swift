//
//  PetChartView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/23/23.
//

import Charts
import SwiftUI

struct PetChartView: View {
    @ObservedObject var pet: Pet
    private let stack = CoreDataStack.shared
    
    @State var shouldPresentAddEliminationView: Bool = false
    @State var peeEntries: [EliminationTotalForDay] = []
    @State var pooEntries: [EliminationTotalForDay] = []
    @State var accidentEntries: [EliminationTotalForDay] = []
    @State var eliminationData: [DataToPlot] = []
    @State var sampleSize: SampleSize = .day
    @State var graphType: GraphType = .bar
    @State var grandTotals = GrandTotals()
    @FetchRequest var eliminations: FetchedResults<Elimination>
    
    init(pet: Pet) {
        self.pet = pet
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        
        _eliminations = FetchRequest(
            entity: Elimination.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Elimination.time, ascending: true)
            ],
            predicate: petPredicate
        )
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(named: "mainColor")
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "mainColorFlipped")], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(named: "mainColor") as Any], for: .normal)
    }
    
    var body: some View {
        ZStack {
            Color("background")
            VStack {
                VStack(spacing: 16) {
                    Picker("Eliminations at a glance", selection: $sampleSize) {
                        ForEach(SampleSize.allCases, id: \.self) { size in
                            Text(size.rawValue)
                        }
                    }
                    .foregroundColor(Color("mainColor"))
                    .pickerStyle(.segmented)
                    .onChange(of: sampleSize) { newValue in
                        grandTotals.rest()
                        processEliminationData(for: newValue)
                    }
                    .onChange(of: eliminations.count) { newValue in
                        grandTotals.rest()
                        processEliminationData(for: sampleSize)
                    }
                    HStack {
                        Chart {
                            if sampleSize == .day {
                                ForEach(peeEntries, id: \.date) { elimination in
                                    BarMark(x: .value("Type", elimination.eliminationType), y: .value("Total", elimination.total), width: 36)
                                        .foregroundStyle(Color("peeColor"))
                                        .cornerRadius(8)
                                }
                                ForEach(pooEntries, id: \.date) { elimination in
                                    BarMark(x: .value("Type", elimination.eliminationType), y: .value("Total", elimination.total), width: 36)
                                        .foregroundStyle(Color("poopColor"))
                                        .cornerRadius(8)
                                }
                                ForEach(accidentEntries, id: \.date) { elimination in
                                    BarMark(x: .value("Type", elimination.eliminationType), y: .value("Total", elimination.total), width: 36)
                                        .foregroundStyle(Color("accidentColor"))
                                        .cornerRadius(8)
                                }
                            } else {
                                ForEach(eliminationData) { elimination in
                                    ForEach(elimination.data, id: \.eliminationType) {
                                        BarMark(x: .value("Date", $0.date, unit: .day), y: .value("Total", $0.total))
                                            .cornerRadius(4)
                                            .foregroundStyle(by: .value("Elimination", elimination.eliminationType))
                                            .position(by: .value("elimination", elimination.eliminationType))
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("system"))
                            )
                        .chartLegend(sampleSize == .day ? .hidden : .visible)
                        .chartXAxis {
                            if sampleSize == .day {
                                AxisMarks(values: ["Pee", "Poop", "Accident"]) { value in
                                    if value.as(String.self) == "Pee" {
                                        AxisValueLabel("Pee", centered: true)
                                    } else if value.as(String.self) == "Poop" {
                                        AxisValueLabel("Poop")
                                    } else {
                                        AxisValueLabel("Accident")
                                    }
                                }
                            } else {
                                AxisMarks (values: .stride (by: .day)) { value in
                                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), centered: true)
                                }
                            }
                        }
                        .chartForegroundStyleScale(
                            [
                                "Pee": Color("peeColor"),
                                "Poop": Color("poopColor"),
                                "Accident": Color("accidentColor")
                            ]
                        )
                    }
                    .padding([.top, .bottom])
                    VStack(spacing: 12) {
                        switch sampleSize {
                        case .day:
                            Text("**Total Daily Potties**")
                                .foregroundColor(Color("mainColor"))
                                .font(.title2)
                        case .week:
                            Text("**Total Weekly Potties**")
                                .foregroundColor(Color("mainColor"))
                                .font(.title2)
                        case .month:
                            Text("**Total Monthly Potties**")
                                .foregroundColor(Color("mainColor"))
                                .font(.title2)
                        }
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pees: **\(grandTotals.pee)**")
                                    .foregroundColor(Color("mainColor"))
                                Text("Poops: **\(grandTotals.poop)**")
                                    .foregroundColor(Color("mainColor"))
                                Text("Accidents: **\(grandTotals.accident)**")
                                    .foregroundColor(Color("mainColor"))
                            }
                            Spacer()
                        }
                    }
                    .padding(.bottom, 36)
                }
            }
            .onAppear {
                peeEntries = []
                pooEntries = []
                accidentEntries = []
                sampleSize = .day
                processEliminationData(for: .day)
            }
            .padding(.horizontal)
        }
    }
    
    func filterEliminations(_ groupDic: [DateComponents : [Elimination]], _ dc: DateComponents) -> [DateComponents : [Elimination]] {
        groupDic.filter {
            let newDate = Calendar.current.date(byAdding: dc, to: Date())
            let newDateStart = Calendar.current.startOfDay(for: newDate!)
            let compDate = Calendar.current.date(from: $0.key)!
            return compDate > newDateStart
        }
    }
    
    private func processEliminationData(for sampleSize: SampleSize) {
        let groupDic = Dictionary(grouping: eliminations) { (elimination) -> DateComponents in
            let date = Calendar.current.dateComponents([.day, .year, .month], from: (elimination.time)!)
            return date
        }
        var newGroup: [DateComponents: [Elimination]] = [:]
        switch sampleSize {
        case .day:
            newGroup = groupDic.filter {
                let compDate = Calendar.current.date(from: $0.key)!
                return Calendar.current.isDateInToday(compDate)
            }
        case .week:
            var dc = DateComponents()
            dc.day = -7
            
            newGroup = filterEliminations(groupDic, dc)
        case .month:
            var dc = DateComponents()
            dc.month = -1
            newGroup = filterEliminations(groupDic, dc)
//        case .sixMonths:
//            var dc = DateComponents()
//            dc.month = -6
//            newGroup = filterEliminations(groupDic, dc)
//        case .year:
//            var dc = DateComponents()
//            dc.year = -1
//            newGroup = filterEliminations(groupDic, dc)
        }
        eliminationData = processEliminations(eliminationsDict: newGroup)
    }
    
    func processEliminations(eliminationsDict: [DateComponents: [Elimination]]) -> [DataToPlot] {
        
        var localEliminationData = [DataToPlot]()
        grandTotals.pee = 0
        grandTotals.poop = 0
        grandTotals.accident = 0
        for (key, value) in eliminationsDict {
            peeEntries = []
            pooEntries = []
            accidentEntries = []
            
            var localPeeTotals = 0
            var localPooTotals = 0
            var localAccidentTotals = 0
            
            for elimination in value {
                switch elimination.type {
                case 1:
                    if elimination.wasAccident {
                        localAccidentTotals += 1
                        grandTotals.accident += 1
                        localPeeTotals += 1
                        grandTotals.pee += 1
                    } else {
                        localPeeTotals += 1
                        grandTotals.pee += 1
                    }
                case 2:
                    if elimination.wasAccident {
                        localAccidentTotals += 1
                        grandTotals.accident += 1
                        localPooTotals += 1
                        grandTotals.poop += 1
                    } else {
                        localPooTotals += 1
                        grandTotals.poop += 1
                    }
                default:
                    print("Unrecognized elimination type")
                }
            }
            peeEntries.append(
                EliminationTotalForDay(eliminationType: "Pee", date: Calendar.current.startOfDay(for: Calendar.current.startOfDay(for: Calendar.current.date(from: key)!)), total: localPeeTotals)
            )
            pooEntries.append(
                EliminationTotalForDay(eliminationType: "Poop", date: Calendar.current.startOfDay(for: Calendar.current.startOfDay(for: Calendar.current.date(from: key)!)), total: localPooTotals)
            )
            accidentEntries.append(
                EliminationTotalForDay(eliminationType: "Accident", date: Calendar.current.startOfDay(for: Calendar.current.startOfDay(for: Calendar.current.date(from: key)!)), total: localAccidentTotals)
            )
            localEliminationData.append(DataToPlot(eliminationType: "Pee", data: peeEntries))
            localEliminationData.append(DataToPlot(eliminationType: "Poop", data: pooEntries))
            localEliminationData.append(DataToPlot(eliminationType: "Accident", data: accidentEntries))
        }
        return localEliminationData
    }
    
}

struct EliminationTotalForDay {
    var id = UUID()
    var eliminationType: String
    var date: Date
    var total: Int
}

struct DataToPlot: Identifiable {
    var id = UUID()
    var eliminationType: String
    var data: [EliminationTotalForDay]
}

enum EliminationChart: String, Plottable {
    case pee = "Pee"
    case poop = "Poop"
    case accident = "Accident"
}

struct GrandTotals {
    var pee: Int = 0
    var poop: Int = 0
    var accident: Int = 0
    
    mutating func rest() {
        pee = 0
        poop = 0
        accident = 0
    }
}
