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
            HStack {
                VStack(alignment: .leading) {
                    Text(entry.pet?.name ?? "")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    HStack(spacing: 4) {
                        Text("Last Pee:")
                            .font(.caption)
                        if entry.eliminations.filter({ $0.type == 1 }).count > 0 {
                            let latestPee = entry.eliminations.filter { $0.type == 1 }[0].time
                            let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                            if Calendar.current.isDateInToday(latestPee!) {
                                Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            } else {
                                VStack {
                                    Text("(\(latestPee!.formatted(.dateTime.month(.twoDigits).day())))")
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
                        if entry.eliminations.filter({ $0.type == 2 }).count > 0 {
                            let latestPoop = entry.eliminations.filter({ $0.type == 2 })[0].time
                            let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                            if Calendar.current.isDateInToday(latestPoop!) {
                                Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
                                    .font(.footnote)
                                    .fontWeight(.bold)
                            } else {
                                VStack {
                                    Text("(\(latestPoop!.formatted(.dateTime.month(.defaultDigits).day(.defaultDigits))))")
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
        }
    }
}

struct LockScreenRectangularWidget_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenRectangularWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: []))
        //            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
