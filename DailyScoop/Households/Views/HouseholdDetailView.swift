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
    private let stack = CoreDataStack.shared
    var body: some View {
        VStack {
            Section {
                List {
                    if let pets = household.pets?.allObjects as? [Pet] {
                        var sortedPets = pets.sorted {
                            $0.birthday! > $1.birthday!
                        }
                        ForEach(sortedPets) { pet in
                            NavigationLink {
                                PetDetailView(pet: pet)
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
                HStack(alignment: .center) {
                    Spacer()
                    Text("Pets")
                        .font(.title)
                    Spacer()
                    Button {
                        shouldPresentAddPetView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $shouldPresentAddPetView) {
                        AddPetView(household: household)
                    }
                }
                .padding(.horizontal, 24)
                
            }
//            Section {
//                if let share = share {
//                    ForEach(share.participants, id: \.self) { participant in
//                        VStack(alignment: .leading) {
//                            Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
//                                .font(.headline)
//                            Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
//                                .font(.subheadline)
//                            Text("Role: \(string(for: participant.role))")
//                                .font(.subheadline)
//                            Text("Permissions: \(string(for: participant.permission))")
//                                .font(.subheadline)
//                        }
//                        .padding(.bottom, 8)
//                    }
//                }
//            } header: {
//                Text("Participants")
//            }
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
        let ageComponents = Calendar.current.dateComponents([.year, .month], from: birthday, to: .now)
        if ageComponents.year! == 0 {
            return "\(ageComponents.month!) months old"
        } else {
            return "\(ageComponents.year!) years old"
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

