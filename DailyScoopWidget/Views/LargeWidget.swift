//
//  LargeWidget.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/4/23.
//

import Charts
import SwiftUI

struct LargeWidget: View {
    var entry: Provider.Entry
    var dummyData: [Date] = []
    
    init(entry: Provider.Entry) {
        self.entry = entry
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
            LinearGradient(colors: [Color("darkPurple"), Color("lightPurple")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("buttonBackground"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
            Image("clipboard")
                .resizable()
                .scaledToFit()
                .frame(height: 18)
                .offset(y: -168)
            if let pet = entry.pet {
                VStack(spacing: 4) {
                    HStack() {
                        if let imageData = pet.picture, let image = UIImage(data: imageData)?.resized(toWidth: 700) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .shadow(color: Color("shadow"), radius: 4, x: 0, y: 1)
                                .padding(.leading, 24)
                        } else {
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .shadow(color: Color("shadow"), radius: 2, x: 0, y: 3)
                                .padding(.leading, 28)
                        }
                        VStack(alignment: .center, spacing: 4) {
                            HStack {
                                Text(pet.name!)
                                    .foregroundColor(Color("mainColor"))
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding(.leading, 20)
                                    .padding(.top, 16)
                                Spacer()
                            }
                            Divider()
                            HStack(spacing: 16) {
                                VStack(alignment: .center) {
                                    if entry.eliminations.filter({ $0.type == 1 }).count > 0 {
                                        let latestPee = entry.eliminations.filter { $0.type == 1 }[0].time
                                        let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                        if Calendar.current.isDateInToday(latestPee!) {
                                            Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("mainColor"))
                                            Text("Last pee")
                                                .foregroundColor(Color("mainColor"))
                                        } else if latestPee! >= yesterday {
                                            VStack {
                                                Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color("mainColor"))
                                                Text("Last pee")
                                                    .foregroundColor(Color("mainColor"))
                                                Text("(yesterday)")
                                                    .font(.footnote)
                                                    .foregroundColor(Color("mainColor"))
                                            }
                                        } else {
                                            VStack {
                                                Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color("mainColor"))
                                                Text("Last pee")
                                                    .foregroundColor(Color("mainColor"))
                                                Text("(\(latestPee!.formatted(.dateTime.month(.twoDigits).day())))")
                                                    .font(.footnote)
                                                    .foregroundColor(Color("mainColor"))
                                            }
                                        }
                                    } else {
                                        VStack {
                                            Text("No data yet")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("accidentColor"))
                                            Text("Last Pee")
                                                .foregroundColor(Color("mainColor"))
                                        }
                                    }
                                }
                                //                        Spacer()
                                VStack(alignment: .center) {
                                    if entry.eliminations.filter({ $0.type == 2 }).count > 0 {
                                        let latestPoop = entry.eliminations.filter({ $0.type == 2 })[0].time
                                        let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                        if Calendar.current.isDateInToday(latestPoop!) {
                                            Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("mainColor"))
                                            Text("Last poop")
                                                .foregroundColor(Color("mainColor"))
                                        } else if latestPoop! >= yesterday {
                                            VStack {
                                                Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color("mainColor"))
                                                Text("Last poop")
                                                    .foregroundColor(Color("mainColor"))
                                                Text("(yesterday)")
                                                    .font(.footnote)
                                                    .foregroundColor(Color("mainColor"))
                                            }
                                        } else {
                                            VStack {
                                                Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(Color("mainColor"))
                                                Text("Last poop")
                                                    .foregroundColor(Color("mainColor"))
                                                Text("(\(latestPoop!.formatted(.dateTime.month(.twoDigits).day())))")
                                                    .font(.footnote)
                                                    .foregroundColor(Color("mainColor"))
                                            }
                                        }
                                    } else {
                                        VStack {
                                            Text("No data yet")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("accidentColor"))
                                            Text("Last poop")
                                                .foregroundColor(Color("mainColor"))
                                        }
                                    }
                                }
                            }
                            HStack {
                                Button {
                                    
                                } label: {
                                    Image("peeSmall")
                                }
                                Spacer()
                                Button {
                                    
                                } label: {
                                    Image("poopSmall")
                                }
                                Spacer()
                                Button {
                                    
                                } label: {
                                    Image("accidentSmall")
                                }
                            }
                            .padding(.bottom, 4)
                            .padding(.trailing, 16)
                        }
                        .padding(.trailing, 24)
                    }
                    Chart {
                        ForEach(entry.eliminations) { elimination in
                            if Calendar.current.isDateInToday(elimination.time!) {
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
                        }
                        ForEach(entry.eliminations) { elimination in
                            if Calendar.current.isDateInToday(elimination.time!) {
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
                        }
                        ForEach(dummyData, id: \.self) { data in
                            PointMark(x: .value("Time", data), y: .value("type", "Poop"))
                                .foregroundStyle(Color.clear)
                        }
                    }
                    .padding([.horizontal, .bottom], 28)
//                    .background(
////                        RoundedRectangle(cornerRadius: 8)
////                            .fill(Color("system"))
//                    )
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .hour, count: 6)) {
                            let date = $0.as(Date.self)
                            if Calendar.current.component(.hour, from: date!) == 0 {
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                    .foregroundStyle(Color("darkPurple"))
                            } else if Calendar.current.component(.hour, from: date!) == 23 {
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                    .foregroundStyle(Color("darkPurple"))
                            } else {
                                AxisGridLine()
                                    .foregroundStyle(Color("darkPurple"))
                            }
                            AxisValueLabel()
                                .foregroundStyle(Color("darkPurple"))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .trailing, values: [0, 1, 2, 3]) { value in
                            if value.as(Int.self) == 1 {
                                AxisValueLabel("Poop", horizontalSpacing: 12)
                                    .foregroundStyle(Color("darkPurple"))
                            } else if value.as(Int.self) == 2 {
                                AxisValueLabel("Pee", horizontalSpacing: 12)
                                    .foregroundStyle(Color("darkPurple"))
                            }
                            AxisGridLine()
                                .foregroundStyle(Color("darkPurple"))
                        }
                    }
                }
            }
        }
    }
}

struct LargeWidget_Previews: PreviewProvider {
    static var previews: some View {
        LargeWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: []))
    }
}
