//
//  IntentHandler.swift
//  DailyScoopIntents
//
//  Created by Tim Bausch on 4/24/23.
//

import CoreData
import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}

extension IntentHandler: HouseholdsIntentHandling {
    func provideHouseholdOptionsCollection(for intent: HouseholdsIntent, with completion: @escaping (INObjectCollection<HouseholdIntent>?, Error?) -> Void) {
        let households = Utilities.readHouseholdsFromDefaults()
        let intents = households.map {
            let household = HouseholdIntent(identifier: $0, display: $0)
            household.name = $0
            return household
        }
        
        let collection = INObjectCollection(items: intents)
        completion(collection, nil)
    }
}
