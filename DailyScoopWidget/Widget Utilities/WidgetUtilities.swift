//
//  WidgetUtilities.swift
//  DailyScoop
//
//  Created by Tim Bausch on 4/24/23.
//

import CoreData
import Foundation

final class WidgetUtilities {
    static let context = CoreDataStack.shared.context
    
    static func fetch(pet: String, from household: String) -> WidgetPet {
        let fetchRequest: NSFetchRequest<Pet>
        fetchRequest = Pet.fetchRequest()
        
        let householdPredicate = NSPredicate(
            format: "household = %@", household
        )
        let petNamePredicate = NSPredicate(format: "name = %@", pet)
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [householdPredicate, petNamePredicate])
        
        fetchRequest.predicate = compoundPredicate
        do {
            let pet = try context.fetch(fetchRequest)
            let newPet = pet.map {
                let eliminations = $0.eliminations?.allObjects as! [Elimination]
                var pee = eliminations.filter { elimination in
                    elimination.type == 1
                }
                let widgetPee = pee.map {
                    WidgetElimination(date: $0.time!, type: .pee)
                }
                var poop = eliminations.filter { elimination in
                    elimination.type == 2
                }
                let widgetPoop = poop.map {
                    WidgetElimination(date: $0.time!, type: .poop)
                }
                var accidents = eliminations.filter { elimination in
                    elimination.wasAccident == true
                }
                let widgetAccidents = accidents.map {
                    WidgetElimination(date: $0.time!, type: .accident)
                }
                return WidgetPet(id: UUID().uuidString, name: $0.name!, birthday: $0.birthday!, weight: $0.weight, peeEntries: widgetPee, poopEntries: widgetPoop, accidentEntries: widgetAccidents)
            }
        } catch {
            print("Error")
        }
        return WidgetPet(id: "", name: "", birthday: Date(), weight: 0.0, peeEntries: [], poopEntries: [], accidentEntries: [])
    }
}
