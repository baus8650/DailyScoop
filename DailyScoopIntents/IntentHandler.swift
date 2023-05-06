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
        let context = CoreDataStack.shared.context
        
        let fetchRequest: NSFetchRequest<Household>
        fetchRequest = Household.fetchRequest()
        
        do {
            let households = try context.fetch(fetchRequest)
            let intents = households.map {
                let household = HouseholdIntent(identifier: $0.name!, display: $0.name!)
                household.name = $0.name!
                print("HOUSEHOLD \($0.name)")
                return household
            }
            
            let collection = INObjectCollection(items: intents)
            completion(collection, nil)
        } catch {
            
        }
    }
}

extension IntentHandler: PetsIntentHandling {
    func providePetOptionsCollection(for intent: PetsIntent, with completion: @escaping (INObjectCollection<PetIntent>?, Error?) -> Void) {
        let context = CoreDataStack.shared.context
        
        let fetchRequest: NSFetchRequest<Pet>
        fetchRequest = Pet.fetchRequest()
        fetchRequest.propertiesToFetch = ["name", "household"]
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Pet.household?.name, ascending: true)]
        
        let petFetchRequest = NSFetchRequest<NSDictionary>(entityName: "Pet")
        //4 Define result type
        petFetchRequest.propertiesToFetch = [
            #keyPath(Pet.name),
            #keyPath(Pet.household.name),
        ]
        petFetchRequest.resultType = .dictionaryResultType
        
        do {
            let pets = try context.fetch(petFetchRequest)
            let intents = pets.map {
                let pet = PetIntent(identifier: $0["name"] as? String ?? "", display: String("\($0["name"] as? String ?? ""), (\($0["household.name"] as? String ?? ""))"))
                pet.name = $0["name"] as? String
                pet.household = $0["household.name"] as? String
                return pet
            }
            let filteredIntents = intents.filter {
                $0.household != nil
            }.sorted {
                $0.household! < $1.household!
            }
            
            let collection = INObjectCollection(items: filteredIntents)
            completion(collection, nil)
        } catch {
            print("JUST COULDNT FETCH THOSE PETS")
        }
    }
}
