//
//  HouseholdDetailView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import CloudKit
import SwiftUI

struct HouseholdDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var household: Household
    @State var shouldPresentAddPetView: Bool = false
    @State private var showShareSheet = false
    @State private var isShowingAccidentView: Pet? = nil
    @State private var share: CKShare?
    @State private var isBirthday: Bool = false
    private let stack = CoreDataStack.shared
    var body: some View {
        VStack {
            Section {
                VStack {
                    List {
                        if let pets = household.pets?.allObjects as? [Pet] {
                            var sortedPets = pets.sorted {
                                $0.birthday! > $1.birthday!
                            }
                            ForEach(sortedPets) { pet in
                                NavigationLink {
                                    PetTabView(pet: pet)
                                } label: {
                                    HStack(spacing: 16) {
                                        if let imageData = pet.picture, let image = UIImage(data: imageData) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 100)
                                                .cornerRadius(8)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(pet.name ?? "")
                                                .font(.headline)
                                            Text("\(Gender(rawValue: pet.gender)!.description)")
                                            Text(calculateYearsOld(with: pet.birthday ?? Date()))
                                                .padding(.bottom, 8)
                                            if calculateBirthday(with: pet.birthday!) {
                                                Text("Happy Birthday, \(pet.name!)! 🎉🎂")
                                            }
                                        }
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                                    Button {
                                        recordQuickPoop(pet: pet)
                                    } label: {
                                        Label("Poop", systemImage: "nose.fill")
                                    }
                                    .tint(.brown)
                                    Button {
                                        recordQuickPee(pet: pet)
                                    } label: {
                                        Label("Pee", systemImage: "drop.fill")
                                    }
                                    .tint(.yellow)
                                    Button {
                                        isShowingAccidentView = pet
                                    } label: {
                                        Label("Oops!", systemImage: "sos.circle.fill")
                                    }
                                    .tint(.red)
                                    
                                })
                                .swipeActions(edge: .trailing, allowsFullSwipe: false, content: {
                                    Button(role: .destructive) {
                                        stack.delete(pet)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                })
                            }
                        }
                    }
                    Text("**Swipe a pet for quick actions**")
                        .font(.caption)
                }
                .onAppear(perform: {
                    self.share = stack.getShare(household)
                })
                .sheet(isPresented: $showShareSheet) {
                    if let share = share {
                        CloudSharingView(share: share, container: stack.ckContainer, household: household)
                    }
                }
                .sheet(item: $isShowingAccidentView) { pet in
                    ReportAccidentView(pet: pet)
                        .presentationDetents([.height(315)])
                }
            } header: {
                Button {
                    shouldPresentAddPetView.toggle()
                } label: {
                    Label("Add Pet", systemImage: "plus")
                }
                .padding(.top, 16)
                .sheet(isPresented: $shouldPresentAddPetView) {
                    AddPetView(household: household)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
        .navigationTitle("\(household.name ?? "Default House")")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if !stack.isShared(object: household) {
                        Task {
                            await createShare(household)
                        }
                    }
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
    
    private func recordQuickPoop(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 2
        elimination.time = Date()
        stack.save()
    }
    
    private func recordQuickPee(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 1
        elimination.time = Date()
        stack.save()
    }
    
    private func recordAccident(pet: Pet) {
        
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
    
    private func calculateBirthday(with birthday: Date) -> Bool {
        let birthdayDC = Calendar.current.dateComponents([.month, .day], from: Calendar.current.startOfDay(for: birthday))
        let todayDC = Calendar.current.dateComponents([.month, .day], from: Calendar.current.startOfDay(for: Date()))
        if birthdayDC.day == todayDC.day && birthdayDC.month == todayDC.month {
            return true
        } else {
            return false
        }
    }
}

extension HouseholdDetailView {
    private func string(for permission: CKShare.ParticipantPermission) -> String {
        switch permission {
        case .unknown:
            return "Unknown"
        case .none:
            return "None"
        case .readOnly:
            return "Read-Only"
        case .readWrite:
            return "Read-Write"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Permission")
        }
    }
    
    private func string(for role: CKShare.ParticipantRole) -> String {
        switch role {
        case .owner:
            return "Owner"
        case .privateUser:
            return "Private User"
        case .publicUser:
            return "Public User"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.Role")
        }
    }
    
    private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
        switch acceptanceStatus {
        case .accepted:
            return "Accepted"
        case .removed:
            return "Removed"
        case .pending:
            return "Invited"
        case .unknown:
            return "Unknown"
        @unknown default:
            fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
        }
    }
    
    private func createShare(_ household: Household) async {
        do {
            let (_, share, _) = try await stack.persistentContainer.share([household], to: nil)
            share[CKShare.SystemFieldKey.title] = household.name
            self.share = share
        } catch {
            print("Failed to create share")
        }
    }
}

