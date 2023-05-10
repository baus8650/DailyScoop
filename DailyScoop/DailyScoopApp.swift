//
//  DailyScoopApp.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI
import WidgetKit


@main
struct DailyScoopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var path: [Pet] = []
    @State var isShowingAccidentView: Bool = false
    @State var petWithAccident: Pet? = nil
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                HouseholdListView()
                    .navigationDestination(for: Pet.self, destination: { pet in
                        PetTabView(pet: pet, selectedTab: 0)
                    })
                    .sheet(item: $petWithAccident) { pet in
                        ReportAccidentView(confirmation: .constant(false), pet: pet)
                            .presentationDetents([.height(315)])
                    }
            }
            .onOpenURL { url in
                path = []
                print("HERE IS URL \(url)")
                guard url.scheme == "dailyscoop",
                      let idString = url.queryParameters["id"],
                      let objectIDURL = URL(string: idString) else {
                    return
                }
                if idString == "x-coredata://EB8922D9-DC06-4256-A21B-DFFD47D7E6DA/MyEntity/p3" {
                    return
                }
                let pet = WidgetUtilities.getPetForDeeplink(pet: objectIDURL)
                switch url.queryParameters["record"] {
                case "pee":
                    let elimination = Elimination(context: CoreDataStack.shared.context)
                    elimination.pet = pet
                    elimination.type = 1
                    elimination.time = Date()
                    CoreDataStack.shared.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    if let pet {
                        path.append(pet)
                    }
                case "poop":
                    let elimination = Elimination(context: CoreDataStack.shared.context)
                    elimination.pet = pet
                    elimination.type = 2
                    elimination.time = Date()
                    CoreDataStack.shared.save()
                    WidgetCenter.shared.reloadAllTimelines()
                    if let pet {
                        path.append(pet)
                    }
                case "accident":
                    if let pet {
                        self.petWithAccident = pet
                        self.isShowingAccidentView = true
                    }
                default:
                    if let pet {
                        path.append(pet)
                    }
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
            .environment(\.managedObjectContext, CoreDataStack.shared.context)
            .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
            .tint(Color("mainColor"))
        }
    }
}

extension URL {
    var queryParameters: [String: String] {
        var parameters = [String: String]()
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = components.queryItems else {
            return parameters
        }
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
}
