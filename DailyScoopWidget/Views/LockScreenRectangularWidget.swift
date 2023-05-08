//
//  LockScreenRectangularWIdget.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/6/23.
//

import SwiftUI
import WidgetKit

struct LockScreenRectangularWidget: View {
    var entry: Provider.Entry
    
    var body: some View {
        
        ZStack {
            //            AccessoryWidgetBackground()
            //                .cornerRadius(8)
            if let pet = entry.pet {
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.pet?.name ?? "")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        HStack(spacing: 4) {
                            Text("Last Pee:")
                                .font(.caption)
                            if pet.eliminations.filter({ $0.type == 1 }).count > 0 {
                                let latestPee = pet.eliminations.filter { $0.type == 1 }[0].date
                                let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                if Calendar.current.isDateInToday(latestPee) {
                                    Text("\(latestPee.formatted(.dateTime.hour().minute()))")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                } else {
                                    VStack {
                                        Text("(\(latestPee.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits))))")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                    }
                                }
                            } else {
                                Text("No data")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            }
                        }
                        HStack(spacing: 4) {
                            Text("Last Poop:")
                                .font(.caption)
                            if pet.eliminations.filter({ $0.type == 2 }).count > 0 {
                                let latestPoop = pet.eliminations.filter({ $0.type == 2 })[0].date
                                let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                if Calendar.current.isDateInToday(latestPoop) {
                                    Text("\(latestPoop.formatted(.dateTime.hour().minute()))")
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                } else {
                                    VStack {
                                        Text("(\(latestPoop.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits))))")
                                            .font(.footnote)
                                            .fontWeight(.bold)
                                    }
                                }
                            } else {
                                Text("No data")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(.leading, 4)
                .widgetURL(URL(string: "dailyscoop://fetchObject?id=\(pet.id)"))
            } else {
                AccessoryWidgetBackground()
                    .cornerRadius(8)
                Text("Open app to refresh or select a pet to view.")
                    .font(.headline)
                    .padding(.horizontal, 4)
            }
        }
    }
}

struct LockScreenRectangularWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenRectangularWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil))
        //            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
