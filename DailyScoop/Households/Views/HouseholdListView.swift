//
//  HouseholdView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import CloudKit
import SwiftUI

struct HouseholdListView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)])
    var households: FetchedResults<Household>
    private let stack = CoreDataStack.shared
    @State var shouldShowAddHouseholdView: Bool = false
    @State private var share: CKShare?
    @State var isShowingDeleteAlert: Bool = false
    @State var selectedHousehold: Household?
    
    init() {
        
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
        
        //        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(named: "mainColor")]
        //        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "mainColor")]
        //        UINavigationBar.appearance().barTintColor = UIColor(named: "background")
    }
    
    var body: some View {
        //        NavigationStack {
        if households.count == 0 {
            Text("No households have been added yet! Add a household by tapping the plus button at the top of the screen.")
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .navigationTitle("Households")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button {
                            shouldShowAddHouseholdView.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .sheet(isPresented: $shouldShowAddHouseholdView) {
                            AddHouseholdView()
                        }
                        
                    }
                }
            
        } else {
            List {
                ForEach(households) { household in
                    NavigationLink {
                        HouseholdDetailView(household: household)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(household.name!)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color("mainColor"))
                            Text("Pets: \(household.pets?.count ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            if let share = stack.getShare(household) {
                                if share.participants.count == 1 {
                                    Text("\(share.participants.count) Member")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("\(share.participants.count) Members")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            selectedHousehold = household
                            isShowingDeleteAlert.toggle()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            
            .onAppear {
                sendHouseholdsToDefaults()
            }
            .alert("Delete Household?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let household = selectedHousehold {
                        stack.delete(household)
                        selectedHousehold = nil
                    }
                }
            } message: {
                Text("Are you sure you want to remove this household? This action cannot be undone and may affect other users linked with this household.")
            }
            .navigationTitle("Households")
            .toolbar {
                //                    ToolbarItem(placement: .navigationBarLeading) {
                //                        EditButton()
                //                    }
                ToolbarItem {
                    Button {
                        shouldShowAddHouseholdView.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $shouldShowAddHouseholdView) {
                        AddHouseholdView()
                            .presentationDetents([.height(125)])
                            .presentationDragIndicator(.visible)
                    }
                    
                }
            }
        }
    }
    
    func sendHouseholdsToDefaults() {
        let householdNames = households.map {
            $0.name!
        }
        Utilities.writeHouseholdsToDefaults(householdNames)
        print("HOUSEHOLDS \(Utilities.readHouseholdsFromDefaults())")
    }
}

struct HouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdListView()
    }
}
