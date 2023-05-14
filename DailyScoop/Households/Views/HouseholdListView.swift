//
//  HouseholdView.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import CloudKit
import SwiftUI

struct HouseholdListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .reverse)])
    var households: FetchedResults<Household>
    private let stack = CoreDataStack.shared
    @State var shouldShowAddHouseholdView: Bool = false
    @State private var share: CKShare?
    @State var isShowingDeleteAlert: Bool = false
    @State var selectedHousehold: Household?
    @State var householdToEdit: Household?
    @State var householdName: String = ""
    @State var isShowingEditHousehold: Bool = false
    
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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
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
                            Spacer()
                            Button {
                                householdName = household.name ?? ""
                                householdToEdit = household
                                isShowingEditHousehold.toggle()
                            } label: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("buttonBackground"))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("mainColor"))
                                            .padding(8)
                                        
                                    )
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color("mainColor")).opacity(0.5)
                                .frame(width: 1, height: 40)
                            Button {
                                selectedHousehold = household
                                isShowingDeleteAlert.toggle()
                            } label: {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("buttonBackground"))
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Image(systemName: "trash.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(Color("accidentColor"))
                                            .padding(8)
                                        
                                    )
                                
                            }
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
                        if households.count == 0 {
                            UserDefaults.standard.setValue("CHOOSE HOUSEHOLD", forKey: "lastAccessedHouse")
                        } else if household.name == UserDefaults.standard.object(forKey: "lastAccessedHouse") as? String ?? "" {
                            UserDefaults.standard.setValue("CHOOSE HOUSEHOLD", forKey: "lastAccessedHouse")
                        }
                        selectedHousehold = nil
                    }
                }
            } message: {
                Text("Are you sure you want to remove this household? This action cannot be undone and may affect other users linked with this household.")
            }
            .alert("Edit Household", isPresented: $isShowingEditHousehold) {
                TextField("New Household Name", text: $householdName)
                Button("Save") {
                    if let household = householdToEdit {
                        household.name = householdName
                        stack.save()
                    }
                }
                
                Button("Cancel", role: .cancel) { }
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

struct HouseholdListView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdListView()
    }
}
