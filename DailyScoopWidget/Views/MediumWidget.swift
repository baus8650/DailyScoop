//
//  MediumWidget.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/4/23.
//

import SwiftUI

struct MediumWidget: View {
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
                Link(destination: (URL(string: "dailyscoop://fetchObject?id=\(pet.id)")!)) {
                    HStack(spacing: 0) {
                        if let imageData = pet.picture, let image = UIImage(data: imageData)?.resized(toWidth: 700) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(color: Color("shadow"), radius: 4, x: 0, y: 1)
                                .padding(.leading, 24)
                        } else {
                            Image(systemName: "pawprint.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(color: Color("shadow"), radius: 2, x: 0, y: 3)
                                .padding(.leading, 28)
                        }
                        VStack(alignment: .center, spacing: 2) {
                            HStack {
                                Text(pet.name)
                                    .foregroundColor(Color("mainColor"))
                                    .frame(width: 156)
                                    .font(.system(size: 28))
                                    .minimumScaleFactor(0.05)
                                    .lineLimit(1)
                                    .fontWeight(.bold)
                                    .padding(.leading, 20)
                                    .padding(.top, 6)
                                Spacer()
                            }
                            Divider()
                            HStack(alignment: .lastTextBaseline, spacing: 16) {
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
                                                        .font(.footnote)
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
//                                        } else {
//                                            VStack {
//                                                Text("\(latestPee!.formatted(.dateTime.hour().minute()))")
//                                                    .font(.headline)
//                                                    .fontWeight(.bold)
//                                                    .foregroundColor(Color("mainColor"))
//                                                Text("Last pee")
//                                                    .foregroundColor(Color("mainColor"))
//                                                Text("(\(latestPee!.formatted(.dateTime.month(.twoDigits).day())))")
//                                                    .font(.footnote)
//                                                    .foregroundColor(Color("mainColor"))
//                                            }
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
                                                        .font(.footnote)
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
//                                        } else {
//                                            VStack {
//                                                Text("\(latestPoop!.formatted(.dateTime.hour().minute()))")
//                                                    .font(.headline)
//                                                    .fontWeight(.bold)
//                                                    .foregroundColor(Color("mainColor"))
//                                                Text("Last poop")
//                                                    .foregroundColor(Color("mainColor"))
//                                                Text("(\(latestPoop!.formatted(.dateTime.month(.twoDigits).day())))")
//                                                    .font(.footnote)
//                                                    .foregroundColor(Color("mainColor"))
//                                            }
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
                                Link(destination: URL(string: "dailyscoop://fetchObject?id=\(pet.id)&record=pee")!) {
                                    Button {
                                        
                                    } label: {
                                        Image("peeSmall")
                                    }
                                }
                                Spacer()
                                Link(destination: URL(string: "dailyscoop://fetchObject?id=\(pet.id)&record=poop")!) {
                                    Button {
                                        
                                    } label: {
                                        Image("poopSmall")
                                    }
                                }
                                Spacer()
                                Link(destination: URL(string: "dailyscoop://fetchObject?id=\(pet.id)&record=accident")!) {
                                    Button {
                                        
                                    } label: {
                                        Image("accidentSmall")
                                    }
                                }
                            }
                            .padding(.bottom, 4)
                        }
                        .padding(.trailing, 24)
                    }
                }
            } else {
                Text(#"Open the app to refresh or tap and hold this widget and choose a pet in the "Edit Widget" menu!"#)
                    .font(.headline)
                    .foregroundColor(Color("mainColor"))
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(width: 300)
            }
        }
    }
}

struct MediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil))
    }
}

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
