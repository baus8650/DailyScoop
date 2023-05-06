//
//  SmallWidget.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/4/23.
//

import SwiftUI

struct SmallWidget: View {
    var entry: Provider.Entry
    
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
                .offset(y: -68)
            if let pet = entry.pet {
                VStack(spacing: 4) {
                    Text(pet.name!)
                        .foregroundColor(Color("mainColor"))
                        .font(.title)
                        .fontWeight(.semibold)
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
            }
        }
    }
}

struct SmallWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: []))
    }
}
