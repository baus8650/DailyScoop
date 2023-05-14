//
//  WidgetUtilities.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/24/23.
//

import CoreData
import Foundation
import NotificationCenter
import WidgetKit

final class WidgetUtilities {
    static let context = CoreDataStack.shared.context
    
    static func fetch(_ pet: String, from household: String) -> Pet? {
        let fetchRequest: NSFetchRequest<Pet>
        fetchRequest = Pet.fetchRequest()
        
        let petPredicate = NSPredicate(format: "name == %@", pet)
        let householdPredicate = NSPredicate(format: "household.name == %@", household)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [petPredicate, householdPredicate])
        fetchRequest.predicate = compoundPredicate
        var pet: Pet?
        
        do {
            let pets = try context.fetch(fetchRequest)
            if pets.count == 1 {
                pet = pets[0]
                return pet
            } else {
                print(pets.map { "\($0.name) from \($0.household?.name)"})
                print("Error, more than one pet fits this description")
            }
        } catch {
            print("Error")
        }
        return pet
    }
    
    static func fetchEliminations(for pet: Pet?) -> [Elimination] {
        if let pet {
            let fetchRequest: NSFetchRequest<Elimination>
            fetchRequest = Elimination.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Elimination.time, ascending: false)]
            
            let petPredicate = NSPredicate(format: "pet == %@", pet)
            fetchRequest.predicate = petPredicate
            do {
                let eliminations = try context.fetch(fetchRequest)
                return eliminations
            } catch {
                print("Could not fetch eliminations")
            }
        }
        
        return []
    }
    
    static func getHousehold(from household: String) -> Household? {
        let fetchRequest: NSFetchRequest<Household>
        fetchRequest = Household.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", household)
        fetchRequest.fetchLimit = 1
        
        do {
            let household = try context.fetch(fetchRequest)
            if household.count == 1 {
                return household[0]
            }
        } catch {
            print("Error getting household")
        }
        return nil
    }
    
    static func getPetForDeeplink(pet: URL) -> Pet? {
        let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: pet)
        print("HERE IS OBJECT ID \(objectID)")
        do {
            let pet = try context.existingObject(with: objectID!)
            
            return pet as? Pet
        } catch {
            print("Error")
        }
        return nil
    }
    
    static func writeHouseholdToDefaults(household: Household) {
        
    }
}
