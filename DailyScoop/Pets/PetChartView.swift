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
    }
    
    var body: some View {
            VStack {
                VStack {
                    Picker("Graph Type", selection: $graphType) {
                        ForEach(GraphType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    Picker("Eliminations at a glance", selection: $sampleSize) {
                        ForEach(SampleSize.allCases, id: \.self) { size in
                            Text(size.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: sampleSize) { newValue in
                        processEliminationData(for: newValue)
                    }
                    HStack {
                        Chart {
                            ForEach(eliminationData) { elimination in
                                ForEach(elimination.data, id: \.eliminationType) {
                                    switch graphType {
                                    case .bar:
                                        BarMark(x: .value("Date", $0.date, unit: .day), y: .value("Total", $0.total))
                                    case .line:
                                        LineMark(x: .value("Date", $0.date, unit: .day), y: .value("Total", $0.total))
                                    }
                                }
                                
                                .foregroundStyle(by: .value("Elimination", elimination.eliminationType))
                                .position(by: .value("elimination", elimination.eliminationType))
                            }
                        }
                        .chartXAxis {
                            AxisMarks (values: .stride (by: .day)) { value in
                                AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), centered: true)
                            }
                        }
                        .chartForegroundStyleScale(
                            [
                                "Pee": .yellow,
                                "Poop": .brown,
                                "Accident": .red
                            ]
                        )
                    }
                    .padding(.top)
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
        case .sixMonths:
            var dc = DateComponents()
            dc.month = -6
            newGroup = filterEliminations(groupDic, dc)
        case .year:
            var dc = DateComponents()
            dc.year = -1
            newGroup = filterEliminations(groupDic, dc)
        }
        eliminationData = processEliminations(eliminationsDict: newGroup)
    }
    
    func processEliminations(eliminationsDict: [DateComponents: [Elimination]]) -> [DataToPlot] {
        
        var localEliminationData = [DataToPlot]()
        
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
                        localPeeTotals += 1
                    } else {
                        localPeeTotals += 1
                    }
                case 2:
                    if elimination.wasAccident {
                        localAccidentTotals += 1
                        localPooTotals += 1
                    } else {
                        localPooTotals += 1
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
