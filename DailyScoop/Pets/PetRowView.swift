//
//  PetRowView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/30/23.
//

import SwiftUI

struct PetRowView: View {
    @State var pet: Pet
    @State var latestPee: Date?
    @State var latestPoop: Date?
    @FetchRequest var eliminations: FetchedResults<Elimination>
    
    init(pet: Pet) {
        _pet = State(initialValue: pet)
        let predicate = NSPredicate(format: "pet == %@", pet)
        
        _eliminations = FetchRequest(entity: Elimination.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Elimination.time, ascending: false)], predicate: predicate)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                Group {
                    if let imageData = pet.picture, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .shadow(color: Color("shadow"), radius: 4, x: 0, y: 1)
                    } else {
                        Image(systemName: "pawprint.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .shadow(color: Color("shadow"), radius: 2, x: 0, y: 3)
                    }
                }
                .padding(.leading, -8)
                .padding(.top, 8)
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Text(pet.name ?? "")
                            .foregroundColor(Color("mainColor"))
                            .font(.title)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("mainColor"))
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 32) {
                        VStack(alignment: .center) {
                            if eliminations.filter({ $0.type == 1 }).count > 0 {
                                let latestPee = eliminations.filter { $0.type == 1 }[0].time
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
                        if eliminations.filter({ $0.type == 2 }).count > 0 {
                            let latestPoop = eliminations.filter({ $0.type == 2 })[0].time
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
                .padding(.horizontal, 4)
            }
            if calculateBirthday(with: pet.birthday!) {
                Text("**Happy Birthday, \(pet.name!)!**")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color("mainColor"))
            }
        }
    }
    
    
    //    private func retrievePees(for pet: Pet) -> [Elimination] {
    //        var pees: [Elimination] = []
    //
    //        if let eliminations = pet.eliminations?.allObjects as? [Elimination] {
    //            pees = eliminations.filter { elimination in
    //                elimination.type == 1
    //            }.sorted {
    //                $0.time! > $1.time!
    //            }
    //        }
    //
    //        return pees
    //    }
    
    //    private func retrievePoops(for pet: Pet) -> [Elimination] {
    //        var poops: [Elimination] = []
    //
    //        if let eliminations = pet.eliminations?.allObjects as? [Elimination] {
    //            poops = eliminations.filter { elimination in
    //                elimination.type == 2
    //            }.sorted {
    //                $0.time! > $1.time!
    //            }
    //        }
    //
    //        return poops
    //    }
    
    private func calculateBirthday(with birthday: Date) -> Bool {
        var calendar = Calendar.current
//        calendar.timeZone = TimeZone(identifier: "UTC")!
        let birthdayDC = calendar.dateComponents([.month, .day], from: calendar.startOfDay(for: birthday))
        let todayDC = calendar.dateComponents([.month, .day], from: calendar.startOfDay(for: Date()))
        if birthdayDC.day == todayDC.day && birthdayDC.month == todayDC.month {
            return true
        } else {
            return false
        }
    }
}

//struct PetRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        PetRowView()
//    }
//}
