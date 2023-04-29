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
    @State var isShowingDeletePetAlert: Bool = false
    @State var petToDelete: Pet?
    @State var isShowingPopover: Bool = false
    @State var isShowingPoopConfirmation: Bool = false
    @State var isShowingPeeConfirmation: Bool = false
    @State var isShowingAccidentConfirmation: Bool = false
    @State var isAnimating: Bool = false
    @FetchRequest var pets: FetchedResults<Pet>
    
    init(household: Household) {
        self.household = household
        let predicate = NSPredicate(format: "household == %@", household)
        
        _pets = FetchRequest(
            entity: Pet.entity(), sortDescriptors: [
                NSSortDescriptor(keyPath: \Pet.birthday, ascending: false)
            ], predicate: predicate
        )
    }
    
    private let stack = CoreDataStack.shared
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    if household.pets?.count == 0 {
                        VStack(spacing: 24) {
                            Text("No pets have been added yet!")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button {
                                shouldPresentAddPetView.toggle()
                            } label: {
                                Label("Add Pet", systemImage: "plus")
                            }
                        }
                        .sheet(isPresented: $shouldPresentAddPetView) {
                            AddPetView(household: household)
                                .presentationDetents([.medium])
                                .presentationDragIndicator(.visible)
                        }
                    } else {
                        Section {
                            List {

                                ForEach(pets) { pet in
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
                                            VStack {
                                                Text(pet.name ?? "")
                                                    .font(.title3)
                                                    .fontWeight(.medium)
                                                    .padding(.vertical ,4)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text("Latest Eliminations")
                                                        .font(.subheadline)
                                                    Divider()
                                                        .padding(.bottom, 2)
                                                    if let latestPee = retrievePees(for: pet).first {
                                                        let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                                        if Calendar.current.isDateInToday(latestPee.time!) {
                                                            Text("Pee: \(latestPee.time!.formatted(.dateTime.hour().minute()))")
                                                                .font(.caption)
                                                        } else if latestPee.time! >= yesterday {
                                                            Text("Pee: Yesterday, \(latestPee.time!.formatted(.dateTime.hour().minute()))")
                                                                .font(.caption)
                                                        } else {
                                                            Text("Pee: \(latestPee.time!.formatted(.dateTime.month(.twoDigits).day().hour().minute()))")
                                                                .font(.caption)
                                                        }
                                                    }
                                                    if let latestPoop = retrievePoops(for: pet).first {
                                                        let yesterday = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: DateComponents(day: -1), to: Date())!)
                                                        if Calendar.current.isDateInToday(latestPoop.time!) {
                                                            Text("Poop: \(latestPoop.time!.formatted(.dateTime.hour().minute()))")
                                                                .font(.caption)
                                                        } else if latestPoop.time! >= yesterday {
                                                            Text("Poop: Yesterday, \(latestPoop.time!.formatted(.dateTime.hour().minute()))")
                                                                .font(.caption)
                                                        } else {
                                                            Text("Poop: \(latestPoop.time!.formatted(.dateTime.month(.twoDigits).day().hour().minute()))")
                                                                .font(.caption)
                                                        }
                                                    }
                                                    if calculateBirthday(with: pet.birthday!) {
                                                        Text("Happy Birthday, \(pet.name!)! 🎉🎂")
                                                            .font(.caption)
                                                            .fontWeight(.bold)
                                                            .padding(.top, 8)
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                                        Button {
                                            recordQuickPoop(pet: pet)
                                            withAnimation(.easeInOut(duration: 0.75)) {
                                                isShowingPoopConfirmation.toggle()
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                withAnimation(.easeOut(duration: 0.75)) {
                                                    isShowingPoopConfirmation = false
                                                }
                                            }
                                        } label: {
                                            Label("Poop", systemImage: "nose.fill")
                                        }
                                        .tint(.brown)
                                        Button {
                                            recordQuickPee(pet: pet)
                                            withAnimation(.easeInOut(duration: 0.75)) {
                                                isShowingPeeConfirmation.toggle()
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                                withAnimation(.easeOut(duration: 0.75)) {
                                                    isShowingPeeConfirmation = false
                                                }
                                            }
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
                                            petToDelete = pet
                                            isShowingDeletePetAlert = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        
                                    })
                                }
                            }
                            Text("**Swipe a pet left or right for quick actions**")
                                .font(.callout)
                                .padding(.vertical, 8)
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
                }
            }
            .zIndex(1)
            if isShowingPoopConfirmation {
                ConfirmationPopover(for: .solid)
                    .zIndex(2)
            }
            if isShowingPeeConfirmation {
                ConfirmationPopover(for: .liquid)
                    .zIndex(2)
            }
            if isShowingAccidentConfirmation {
                ConfirmationPopover(for: .none)
                    .zIndex(2)
            }
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
            ReportAccidentView(confirmation: $isShowingAccidentConfirmation, pet: pet)
                .presentationDetents([.height(315)])
                .onDisappear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeOut(duration: 0.75)) {
                            self.isShowingAccidentConfirmation = false
                        }
                    }
                }
        }
        .alert("Delete Pet", isPresented: $isShowingDeletePetAlert, actions: {
            Button(role: .destructive) {
                if let petToDelete {
                    stack.delete(petToDelete)
                }
                petToDelete = nil
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("Are you sure you want to delete \(petToDelete?.name ?? "this pet")? Deleting \(petToDelete?.name ?? "this pet") will affect all users you share this household with. This action is permanent cannot be undone!")
        })
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
    
    private func retrievePees(for pet: Pet) -> [Elimination] {
        var pees: [Elimination] = []
        
        if let eliminations = pet.eliminations?.allObjects as? [Elimination] {
            pees = eliminations.filter { elimination in
                elimination.type == 1
            }.sorted {
                $0.time! > $1.time!
            }
        }
        
        return pees
    }
    
    private func retrievePoops(for pet: Pet) -> [Elimination] {
        var poops: [Elimination] = []
        
        if let eliminations = pet.eliminations?.allObjects as? [Elimination] {
            poops = eliminations.filter { elimination in
                elimination.type == 2
            }.sorted {
                $0.time! > $1.time!
            }
        }
        
        return poops
    }
    
    private func calculateYearsOld(with birthday: Date) -> String {
        let beginningOfDay = Calendar.current.startOfDay(for: birthday)
        let ageComponents = Calendar.current.dateComponents([.year, .month, .day], from: beginningOfDay, to: .now)
        print("TESTING \(ageComponents.year), month \(ageComponents.month), day \(ageComponents.day)")
        if ageComponents.year! == 0 {
            if ageComponents.month! == 0 {
                let formatString: String = NSLocalizedString("pet_age_days", comment: "Day string determined in Localized.stringsdict")
                print("IN DAYS \(String.localizedStringWithFormat(formatString, ageComponents.day!))")
                return String.localizedStringWithFormat(formatString, ageComponents.day!)
            } else {
                let formatString: String = NSLocalizedString("pet_age_months", comment: "Month string determined in Localized.stringsdict")
                return String.localizedStringWithFormat(formatString, ageComponents.month!)
            }
        } else {
            let formatString: String = NSLocalizedString("pet_age_years", comment: "Year string determined in Localized.stringsdict")
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

