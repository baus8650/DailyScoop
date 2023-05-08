//
//  SmallWidget.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/4/23.
//

import SwiftUI
import WidgetKit

struct SmallWidget: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack(alignment: .center) {
            ZStack(alignment: .top) {
                LinearGradient(colors: [Color("colorGradientStart"), Color("colorGradientEnd")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("clipboardColor"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                Image("clipboard")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .padding(.top, 2)
            }
            if let pet = entry.pet {
                VStack(spacing: 4) {
                    Text(pet.name)
                        .foregroundColor(Color("mainColor"))
                        .frame(width: 100)
                        .font(.system(size: 28))
                        .minimumScaleFactor(0.05)
                        .lineLimit(1)
                        .fontWeight(.bold)
                    VStack(alignment: .center) {
                        if pet.eliminations.filter({ $0.type == 1 }).count > 0 {
                            let latestPee = pet.eliminations.filter { $0.type == 1 }[0].date
                            let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                            if Calendar.current.isDateInToday(latestPee) {
                                Text("\(latestPee.formatted(.dateTime.hour().minute()))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("mainColor"))
                                Text("Last pee")
                                    .foregroundColor(Color("mainColor"))
                            } else {
                                VStack {
                                    HStack(spacing: 2) {
                                        Text("\(latestPee.formatted(.dateTime.hour().minute()))")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("accidentColor"))
                                        Text("(\(latestPee.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits))))")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("accidentColor"))
                                    }
                                    Text("Last pee")
                                        .foregroundColor(Color("mainColor"))
                                }
//                            } else {
//                                VStack {
//                                    Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(Color("mainColor"))
//                                    Text("Last pee")
//                                        .foregroundColor(Color("mainColor"))
//                                    Text("(\(latestPee!.formatted(.dateTime.month(.twoDigits).day())))")
//                                        .font(.caption)
//                                        .foregroundColor(Color("mainColor"))
//                                }
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
                    VStack(alignment: .center) {
                        if pet.eliminations.filter({ $0.type == 2 }).count > 0 {
                            let latestPoop = pet.eliminations.filter({ $0.type == 2 })[0].date
                            let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                            if Calendar.current.isDateInToday(latestPoop) {
                                Text("\(latestPoop.formatted(.dateTime.hour().minute()))")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("mainColor"))
                                Text("Last poop")
                                    .foregroundColor(Color("mainColor"))
                            } else {
                                VStack {
                                    HStack(spacing: 2) {
                                        Text("\(latestPoop.formatted(.dateTime.hour().minute()))")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("accidentColor"))
                                        Text("(\(latestPoop.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits))))")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color("accidentColor"))
                                    }
                                    Text("Last poop")
                                        .foregroundColor(Color("mainColor"))
                                }
//                            } else {
//                                VStack {
//                                    Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
//                                        .font(.headline)
//                                        .fontWeight(.bold)
//                                        .foregroundColor(Color("mainColor"))
//                                    Text("Last poop")
//                                        .foregroundColor(Color("mainColor"))
//                                    Text("(\(latestPoop!.formatted(.dateTime.month(.twoDigits).day())))")
//                                        .font(.footnote)
//                                        .foregroundColor(Color("mainColor"))
//                                }
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
                .widgetURL(URL(string: "dailyscoop://fetchObject?id=\(pet.id)"))
            } else {
                Text("Open the app or choose a pet!")
                    .font(.headline)
                    .foregroundColor(Color("mainColor"))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
        }
    }
}

struct SmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
