//
//  DailyScoopApp.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import SwiftUI

@main
struct DailyScoopApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HouseholdListView()
                .environment(\.managedObjectContext, CoreDataStack.shared.context)
        }
    }
}
