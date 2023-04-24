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
    @Binding var showEditPetView: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                if let imageData = pet.picture, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(8)
                }
                Spacer()
            }
            VStack(alignment: .leading) {
                Text("Gender: \(Gender(rawValue: pet.gender)!.description)")
                Text("Age: \(calculateYearsOld(with: pet.birthday ?? Date()))")
                Text("Weight: \(formatWeight(pet.weight)) lbs")
                    .padding(.bottom, 8)
            }
            Spacer()
        }
        .padding(.vertical)
        .sheet(isPresented: $showEditPetView, content: {
            EditPetView(pet: pet)
        })
    }
    
    private func calculateYearsOld(with birthday: Date) -> String {
        let beginningOfDay = Calendar.current.startOfDay(for: birthday)
        let ageComponents = Calendar.current.dateComponents([.year, .month], from: beginningOfDay, to: .now)
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
