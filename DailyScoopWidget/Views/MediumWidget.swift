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
                                .padding(.top, 4)
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
                    }
                    .padding(.trailing, 24)
                }
            }
        }
    }
}

struct MediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidget(entry: Provider.Entry(date: Date(), configuration: PetsIntent(), pet: nil, eliminations: []))
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
