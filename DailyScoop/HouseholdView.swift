//
//  SwiftUIView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 5/13/23.
//

import CloudKit
import SwiftUI

struct HouseholdView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Household.name, ascending: true)])
    var households: FetchedResults<Household>
    private let stack = CoreDataStack.shared
    @State private var share: CKShare?
    @State var household: Household?
    @State var showShareSheet: Bool = false
    @State var shouldPresentAddPetView: Bool = false
    @State var shouldShowAddHouseholdView: Bool = false
    @State var householdName: String = ""
    @State var shouldPresentListView: Bool = false
    
    init(lastAccessed: String) {
        let appearence = UINavigationBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.backgroundColor = UIColor(named: "background")
        appearence.titleTextAttributes = [.foregroundColor: UIColor(named: "mainColor")]
        appearence.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "mainColor")]
        appearence.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = appearence
        UINavigationBar.appearance().scrollEdgeAppearance = appearence
        
        UINavigationBar.appearance().compactAppearance = appearence
        UINavigationBar.appearance().tintColor = UIColor(named: "mainColor")
        if lastAccessed != "" {
            let fetchedHousehold = WidgetUtilities.getHousehold(from: lastAccessed)
            if let fetchedHousehold {
                _household = State(initialValue: fetchedHousehold)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            if let household {
                HouseholdDetailView(household: household)
            } else {
                VStack(spacing: 24) {
                    if UserDefaults.standard.object(forKey: "lastAccessedHouse") as? String ?? "" == "" {
                        Text("Welcome to Daily Scoop!")
                            .font(.title)
                            .foregroundColor(Color("mainColor"))
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Let's select a household to view or add a new one by tapping the house at the top left of the screen.")
                            //                        .frame(maxWidth: .infinity)
                            Text("The app will open to your last-viewed household but you can always switch between households (if you have more than one) by tapping the house button again!")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color("mainColor"))
                        //                    .navigationTitle("Select A Household")
                        //                    .padding(.horizontal, 24)
                    } else if UserDefaults.standard.object(forKey: "lastAccessedHouse") as? String ?? "" == "CHOOSE HOUSEHOLD" {
                        //                    VStack(spacing: 24) {
                        Text("Uh Oh!")
                            .font(.title)
                            .foregroundColor(Color("mainColor"))
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Looks like you may have deleted the last-viewed household. Not to worry! Just select a new household or add a new one from the house button at the top of the screen!")
                            Text("Remember, the app opens to your last-viewed household but you can always switch between households (if you have more than one) by tapping the house button again!")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color("mainColor"))
                        //                    }
                        //                    .navigationTitle("Select A Household")
                        //                    .padding(.horizontal, 24)
                    } else if households.count == 0 {
                        //                    VStack(spacing: 24) {
                        Text("Uh Oh!")
                            .font(.title)
                            .foregroundColor(Color("mainColor"))
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Looks like you may have deleted the last-viewed household. Not to worry! Just select a new household or add a new one from the house button at the top of the screen!")
                            Text("Remember, the app opens to your last-viewed household but you can always switch between households (if you have more than one) by tapping the house button again!")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color("mainColor"))
                        //                    }
                    } else {
                        Text("Uh Oh!")
                            .font(.title)
                            .foregroundColor(Color("mainColor"))
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Looks like you may have edited the name of last-viewed household. Not to worry! Just select a new household or add a new one from the house button at the top of the screen!")
                            Text("Remember, the app opens to your last-viewed household but you can always switch between households (if you have more than one) by tapping the house button again!")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(Color("mainColor"))
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .onChange(of: households.count, perform: { newValue in
            if newValue == 0 {
                self.shouldPresentListView = false
            }
        })
        .sheet(isPresented: $showShareSheet) {
            if let share = share {
                if let household {
                    CloudSharingView(share: share, container: stack.ckContainer, household: household)
                }
            }
        }
        .sheet(isPresented: $shouldPresentListView, onDismiss: {
            if households.count == 0 {
                self.household = nil
            }
        }, content: {
            HouseholdListView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        })
//        .sheet(isPresented: $shouldPresentListView, content: {
//            HouseholdListView()
//                .presentationDetents([.medium, .large])
//                .presentationDragIndicator(.visible)
//        })
//        .sheet(isPresented: $shouldShowAddHouseholdView) {
//            AddHouseholdView()
//                .presentationDetents([.height(125)])
//                .presentationDragIndicator(.visible)
//        }
        .sheet(isPresented: $shouldPresentAddPetView) {
            if let household {
                AddPetView(household: household)
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
            }
        }
        .alert("Let's add a household!", isPresented: $shouldShowAddHouseholdView) {
            TextField("Household name", text: $householdName)
                .autocapitalization(.words)
            Button(role: .cancel) {
                
            } label: {
                Text("Cancel")
            }
            Button {
                let newHousehold = Household(context: managedObjectContext)
                newHousehold.name = householdName
                stack.save()
                self.household = WidgetUtilities.getHousehold(from: householdName)
                UserDefaults.standard.set(householdName, forKey: "lastAccessedHouse")
                householdName = ""
            } label: {
                Text("Save")
            }
        } message: {
            Text("What's the name of this household?")
        }
        .navigationTitle("\(household?.name ?? "Select A Household")")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let household {
                        if !stack.isShared(object: household) {
                            Task {
                                await createShare(household)
                            }
                        }
                    }
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shouldPresentAddPetView = true
                } label: {
                    Image("addPet")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    getMenu()
                    if households.count > 0 {
                        Button {
                            print("I PRESSED THE BUTTON WHY NO WORK \(shouldPresentListView)")
                            self.shouldPresentListView = true
                            print("I PRESSED THE BUTTON WHY NO WORK after toggle \(shouldPresentListView)")
                        } label: {
                            Label("Manage Households", systemImage: "wrench.and.screwdriver.fill")
                        }
                    }
                    Button {
                        shouldShowAddHouseholdView = true
                    } label: {
                        Label("Add New Household", systemImage: "plus")
                    }
                } label: {
                    Button {
                        
                    } label: {
                        Image(systemName: "house.fill")
                    }
                }
            }
        }
    }
    
    private func getMenu() -> some View {
        ForEach(households) { household in
            Button {
                self.household = household
                UserDefaults.standard.set(household.name ?? "", forKey: "lastAccessedHouse")
                UserDefaults.standard.synchronize()
                print("AFTER SAVING \(UserDefaults.standard.object(forKey: "lastAccessedHouse"))")
            } label: {
                Text(household.name ?? "")
            }
        }
    }
}

struct HouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdView(lastAccessed: UserDefaults.standard.object(forKey: "lastAccessedHouse") as? String ?? "")
    }
}

extension HouseholdView {
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
    
    @MainActor
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
