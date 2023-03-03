//
//  ReportAccidentView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/25/23.
//

import SwiftUI

struct ReportAccidentView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    private let stack = CoreDataStack.shared
    var pet: Pet
    @State var time: Date = Date()
    var body: some View {
        VStack(spacing: -8) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(Color(uiColor: UIColor.secondaryLabel))
                .frame(width: 48, height: 3)
            VStack(spacing: 16) {
                Text("Looks like \(pet.name!) had an accident!")
                    .font(.title2)
                    .fontWeight(.medium)
                DatePicker("Time", selection: $time)
                    .padding(.horizontal, 20)
                VStack(spacing: 16) {
                    Button {
                        recordAccidentPee(pet: pet)
                        dismiss()
                    } label: {
                        Text("\(pet.gender == 0 ? "She" : "He") peed.")
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.yellow)
                            .frame(width: 200)
                    )
                    
                    Button {
                        recordAccidentPoop(pet: pet)
                        dismiss()
                    } label: {
                        Text("\(pet.gender == 0 ? "She" : "He") pooped.")
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.brown)
                            .frame(width: 200)
                    )
                    Button {
                        dismiss()
                    } label: {
                        Text("False alarm!")
                    }
                    .buttonStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(uiColor: UIColor.secondarySystemBackground))
                            .frame(width: 200)
                    )
                }
            }
            .padding(.top)
        }
    }
    
    private func recordAccidentPoop(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 2
        elimination.wasAccident = true
        elimination.time = time
        stack.save()
    }
    
    private func recordAccidentPee(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 1
        elimination.wasAccident = true
        elimination.time = time
        stack.save()
    }
}
//
//struct ReportAccidentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportAccidentView()
//    }
//}
