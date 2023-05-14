//
//  PetDetailView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import Charts
import SwiftUI

struct PetDetailView: View {
    @ObservedObject var pet: Pet
    @State var showEditPetView: Bool = false
    @FetchRequest var eliminations: FetchedResults<Elimination>
    @State var pees: [Elimination] = []
    @State var poops: [Elimination] = []
    var dummyData: [Date] = []
    
    init(pet: Pet) {
        self.pet = pet
        let datePredicate = NSPredicate(format: "time >= %@", Calendar.current.startOfDay(for: Date()) as CVarArg)
        let petPredicate = NSPredicate(format: "pet == %@", pet)
        
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, petPredicate])
        
        _eliminations = FetchRequest(
            entity: Elimination.entity(),
            sortDescriptors: [],
            predicate: predicate
        )
        
        let beginningOfDay = Calendar.current.startOfDay(for: Date())
        self.dummyData = [
            beginningOfDay,
            Calendar.current.date(byAdding: DateComponents(hour: 6), to: beginningOfDay)!,
            Calendar.current.date(byAdding: DateComponents(hour: 12), to: beginningOfDay)!,
            Calendar.current.date(byAdding: DateComponents(hour: 18), to: beginningOfDay)!,
            Calendar.current.date(byAdding: DateComponents(hour: 23, minute: 59), to: beginningOfDay)!
        ]
        
    }
    
    var body: some View {
        ZStack {
            Color("background")
            VStack(spacing: 24) {
                HStack(spacing: 24) {
                    if let imageData = pet.picture, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .clipShape(Circle())
                            .shadow(color: Color("shadow"), radius: 4, x: 0, y: 1)
                    } else {
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .shadow(color: Color("shadow"), radius: 10, x: 0, y: 3)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birthday: \(pet.birthday!.formatted(.dateTime.month(.abbreviated).day().year()))")
                            .foregroundColor(Color("mainColor"))
                        Text("Gender: \(Gender(rawValue: pet.gender)!.description)")
                            .foregroundColor(Color("mainColor"))
                        Text("Weight: \(formatWeight(pet.weight)) lbs")
                            .foregroundColor(Color("mainColor"))
                    }
                }
                .padding(.top, 4)
                Button {
                    showEditPetView = true
                } label: {
                    Text("Edit Pet")
                        .font(.footnote)
                        .fontWeight(.bold)
                }
                .padding(.top, -18)
                .padding(.bottom, -24)
                Chart {
                    ForEach(eliminations) { elimination in
                        if elimination.type == 1 {
                            if elimination.wasAccident {
                                RectangleMark(x: .value("Time", elimination.time!), y: .value("type", 2), width: 12, height: 28)
                                    .foregroundStyle(
                                        LinearGradient(colors: [Color("peeColor"), Color("accidentColor")], startPoint: .top, endPoint: .bottom)
                                    )
                                    .cornerRadius(6)
                            } else {
                                RectangleMark(x: .value("Time", elimination.time!), y: .value("type", 2), width: 12, height: 28)
                                    .foregroundStyle(Color("peeColor"))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    ForEach(eliminations) { elimination in
                        if elimination.type == 2 {
                            if elimination.wasAccident {
                                RectangleMark(x: .value("Time", elimination.time!), y: .value("type", 1), width: 12, height: 28)
                                    .foregroundStyle(
                                        LinearGradient(colors: [Color("poopColor"), Color("accidentColor")], startPoint: .top, endPoint: .bottom)
                                    )
                                    .cornerRadius(6)
                            } else {
                                RectangleMark(x: .value("Time", elimination.time!), y: .value("type", 1), width: 12, height: 28)
                                    .foregroundStyle(Color("poopColor"))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    ForEach(dummyData, id: \.self) { data in
                        PointMark(x: .value("Time", data), y: .value("type", "Poop"))
                            .foregroundStyle(Color.clear)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("system"))
                )
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 6)) {
                        let date = $0.as(Date.self)
                        if Calendar.current.component(.hour, from: date!) == 0 {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        } else if Calendar.current.component(.hour, from: date!) == 23 {
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        } else {
                            AxisGridLine()
                        }
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing, values: [0, 1, 2, 3]) { value in
                        if value.as(Int.self) == 1 {
                            AxisValueLabel("Poop", horizontalSpacing: 12)
                        } else if value.as(Int.self) == 2 {
                            AxisValueLabel("Pee", horizontalSpacing: 12)
                        }
                        AxisGridLine()
                    }
                }
                .padding(.bottom, 24)
                VStack(spacing: 16) {
                    Text("Total Daily Potties")
                        .foregroundColor(Color("mainColor"))
                        .font(.title2)
                        .fontWeight(.bold)
                    HStack {
                        Text("Pee: **\(getPeeTotals())**")
                            .foregroundColor(Color("mainColor"))
                        Spacer()
                        Text("Poop: **\(getPoopTotals())**")
                            .foregroundColor(Color("mainColor"))
                        Spacer()
                        Text("Accidents: **\(getAccidentTotals())**")
                            .foregroundColor(Color("mainColor"))
                    }
                }
                .padding(.bottom, 48)
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .sheet(isPresented: $showEditPetView) {
                EditPetView(pet: pet)
            }
        }
    }
    
    private func getPeeTotals() -> Int {
        let pees = eliminations.filter {
            $0.type == 1
        }
        return pees.count
    }
    
    private func getPoopTotals() -> Int {
        let poops = eliminations.filter {
            $0.type == 2
        }
        
        return poops.count
    }
    
    private func getAccidentTotals() -> Int {
        let accidents = eliminations.filter {
            $0.wasAccident == true
        }
        
        return accidents.count
    }
    
    private func calculateYearsOld(with birthday: Date) -> String {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let beginningOfDay = calendar.startOfDay(for: birthday)
        let ageComponents = calendar.dateComponents([.year, .month], from: beginningOfDay, to: .now)
        if ageComponents.year! == 0 {
            let formatString : String = NSLocalizedString("pet_age_months", comment: "Month string determined in Localized.stringsdict")
            return String.localizedStringWithFormat(formatString, ageComponents.month!)
        } else {
            let formatString : String = NSLocalizedString("pet_age_years", comment: "Year string determined in Localized.stringsdict")
            return String.localizedStringWithFormat(formatString, ageComponents.year!)
        }
    }
    
    func formatWeight(_ weight : Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: weight)
        let formattedValue = formatter.string(from: number) ?? "0"
        return formattedValue
    }
}
