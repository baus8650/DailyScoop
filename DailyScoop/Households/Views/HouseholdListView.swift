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
    var body: some View {
        NavigationView {
            List {
                ForEach(households) { household in
                    NavigationLink {
                        HouseholdDetailView(household: household)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(household.name!)")
                                .font(.title2)
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
        }
    }
}

struct HouseholdView_Previews: PreviewProvider {
    static var previews: some View {
        HouseholdListView()
    }
}
