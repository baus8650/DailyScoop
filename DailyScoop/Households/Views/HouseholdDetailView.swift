//
//  HouseholdDetailView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import CloudKit
import SwiftUI
import WidgetKit

struct HouseholdDetailView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
//    @ObservedObject var household: Household
    @State var household: Household
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
    @State private var path = NavigationPath()
    @FetchRequest var pets: FetchedResults<Pet>
    
    init(household: Household) {
        print("IM IN THE FREAKING INIT")
        _household = State(initialValue: household)
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
                    if pets.count == 0 {
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
//                        .sheet(isPresented: $shouldPresentAddPetView) {
//                            AddPetView(household: household)
//                                .presentationDetents([.height(350)])
//                                .presentationDragIndicator(.visible)
//                        }
                    } else {
//                        Section {
                            List {
                                ForEach(pets) { pet in
                                    PetRowView(pet: pet)
                                        .background(
                                            NavigationLink("", destination: PetTabView(pet: pet))
                                                .opacity(0)
                                        )
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
                                                Label("Poop", image: "poopSmall")
                                                
                                            }
                                            .tint(.brown)
                                            .frame(height: 12)
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
                                                Label("Pee", image: "peeSmall")
                                            }
                                            .tint(.yellow)
                                            Button {
                                                isShowingAccidentView = pet
                                            } label: {
                                                Label("Oops!", image: "accidentSmall")
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
                                            .tint(.red)
                                        })
                                }
                            }
                            Text("**Swipe a pet left or right for quick actions**")
                            .foregroundColor(Color("mainColor"))
                                .font(.callout)
                                .padding(.vertical, 8)
//                        } header: {
//                            Button {
//                                shouldPresentAddPetView.toggle()
//                            } label: {
//                                Label("Add Pet", systemImage: "plus")
//                            }
//                            .padding(.top, 16)
//                            .sheet(isPresented: $shouldPresentAddPetView) {
//                                AddPetView(household: household)
//                                    .presentationDetents([.medium])
//                                    .presentationDragIndicator(.visible)
//                            }
//                        }
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
//        .sheet(isPresented: $showShareSheet) {
//            if let share = share {
//                CloudSharingView(share: share, container: stack.ckContainer, household: household)
//            }
//        }
        .sheet(isPresented: $shouldPresentAddPetView) {
            AddPetView(household: household)
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $isShowingAccidentView) { pet in
            ReportAccidentView(confirmation: $isShowingAccidentConfirmation, pet: pet)
                .presentationDetents([.height(315)])
                .presentationDragIndicator(.visible)
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
    }
    
    private func recordQuickPoop(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 2
        elimination.time = Date()
        stack.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func recordQuickPee(pet: Pet) {
        var elimination = Elimination(context: managedObjectContext)
        elimination.pet = pet
        elimination.type = 1
        elimination.time = Date()
        stack.save()
        WidgetCenter.shared.reloadAllTimelines()
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


