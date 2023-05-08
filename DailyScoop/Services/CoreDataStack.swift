//
//  CoreDataStack.swift
//  DailyScoop
//
//  Created by Tim Bausch on 2/11/23.
//

import Foundation
import CoreData
import CloudKit
import UIKit

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    static var preview: CoreDataStack = {
        let result = CoreDataStack(inMemory: true)
        let viewContext = result.persistentContainer.viewContext
        let pet = Pet(context: viewContext)
        pet.name = "Penny"
        pet.birthday = Calendar.current.date(from: DateComponents(year: 2012, month: 9, day: 5))
        pet.gender = 1
        pet.weight = 27.5
        var image = UIImage(named: "penny")!
        image = image.rotateImage()!
        let data = image.jpegData(compressionQuality: 1.0)
        pet.picture = data
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let pee = Elimination(context: viewContext)
        pee.pet = pet
        pee.time = Calendar.current.date(byAdding: DateComponents(hour: 8, minute: 27), to: startOfDay)
        pee.type = 1
        
        let poop = Elimination(context: viewContext)
        poop.pet = pet
        poop.time = Calendar.current.date(byAdding: DateComponents(hour: 8, minute: 31), to: startOfDay)
        poop.type = 2
        
        let pee2 = Elimination(context: viewContext)
        pee2.pet = pet
        pee2.time = Calendar.current.date(byAdding: DateComponents(hour: 12, minute: 48), to: startOfDay)
        pee2.type = 1
        
        let pee3 = Elimination(context: viewContext)
        pee3.pet = pet
        pee3.time = Calendar.current.date(byAdding: DateComponents(hour: 18, minute: 7), to: startOfDay)
        pee3.type = 1
        
        let poop2 = Elimination(context: viewContext)
        poop2.pet = pet
        poop2.time = Calendar.current.date(byAdding: DateComponents(hour: 18, minute: 9), to: startOfDay)
        poop2.type = 2
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    var ckContainer: CKContainer {
        let storeDescription = persistentContainer.persistentStoreDescriptions.first
        guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get container identifier")
        }
        return CKContainer(identifier: identifier)
    }
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    var privatePersistentStore: NSPersistentStore {
        guard let privateStore = _privatePersistentStore else {
            fatalError("Private store is not set")
        }
        return privateStore
    }
    
    var sharedPersistentStore: NSPersistentStore {
        guard let sharedStore = _sharedPersistentStore else {
            fatalError("Shared store is not set")
        }
        return sharedStore
    }
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "DailyScoop")
        
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("Unable to get persistentStoreDescription")
        }
        let storesURL = URL.storeURL(for: WidgetConstants.suiteName, databaseName: "DailyScoop")
        privateStoreDescription.url = storesURL.appendingPathComponent("private.sqlite")
        
        // TODO: 1
        let sharedStoreURL = storesURL.appendingPathComponent("shared.sqlite")
        guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
            fatalError("Copying the private store description returned an unexpected value.")
        }
        sharedStoreDescription.url = sharedStoreURL
        privateStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.timbausch.FamilyTracker")
        
        // TODO: 2
        guard let containerIdentifier = privateStoreDescription.cloudKitContainerOptions?.containerIdentifier else {
            fatalError("Unable to get containerIdentifier")
        }
        let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        sharedStoreOptions.databaseScope = .shared
        sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
        
        // TODO: 3
        
        container.persistentStoreDescriptions.append(sharedStoreDescription)
        
        // TODO: 4
        
        container.loadPersistentStores { loadedStoreDescription, error in
            if let error = error as NSError? {
                fatalError("Failed to load persistent stores: \(error)")
            } else if let cloudKitContainerOptions = loadedStoreDescription
                .cloudKitContainerOptions {
                guard let loadedStoreDescritionURL = loadedStoreDescription.url else { return }
                if cloudKitContainerOptions.databaseScope == .private {
                    let privateStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._privatePersistentStore = privateStore
                } else if cloudKitContainerOptions.databaseScope == .shared {
                    let sharedStore = container.persistentStoreCoordinator
                        .persistentStore(for: loadedStoreDescritionURL)
                    self._sharedPersistentStore = sharedStore
                }
            }
        }

        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentCloudKitContainer(name: "DailyScoop")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private init() {}
}

// MARK: Save or delete from Core Data
extension CoreDataStack {
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("ViewContext save error: \(error)")
            }
        }
    }
    
    func delete(_ pet: Pet) {
        context.perform {
            self.context.delete(pet)
            self.save()
        }
    }
    
    func delete(_ elimination: Elimination) {
        context.perform {
            self.context.delete(elimination)
            self.save()
        }
    }
    
    func delete(_ household: Household) {
        context.perform {
            self.context.delete(household)
            self.save()
        }
    }
}

extension CoreDataStack {
    func isShared(object: NSManagedObject) -> Bool {
        isShared(objectID: object.objectID)
    }
    
    func canEdit(object: NSManagedObject) -> Bool {
        return persistentContainer.canUpdateRecord(forManagedObjectWith: object.objectID)
    }
    
    func canDelete(object: NSManagedObject) -> Bool {
        return persistentContainer.canDeleteRecord(forManagedObjectWith: object.objectID)
    }
    
    func isOwner(object: NSManagedObject) -> Bool {
        guard isShared(object: object) else { return false }
        guard let share = try? persistentContainer.fetchShares(matching: [object.objectID])[object.objectID] else {
            print("Get ckshare error")
            return false
        }
        if let currentUser = share.currentUserParticipant, currentUser == share.owner {
            return true
        }
        return false
    }
    
    func getShare(_ household: Household) -> CKShare? {
        guard isShared(object: household) else { return nil }
        guard let shareDictionary = try? persistentContainer.fetchShares(matching: [household.objectID]),
              let share = shareDictionary[household.objectID] else {
            print("Unable to get CKShare")
            return nil
        }
        share[CKShare.SystemFieldKey.title] = household.name
        return share
    }
    
    private func isShared(objectID: NSManagedObjectID) -> Bool {
        var isShared = false
        if let persistentStore = objectID.persistentStore {
            if persistentStore == sharedPersistentStore {
                isShared = true
            } else {
                let container = persistentContainer
                do {
                    let shares = try container.fetchShares(matching: [objectID])
                    if shares.first != nil {
                        isShared = true
                    }
                } catch {
                    print("Failed to fetch share for \(objectID): \(error)")
                }
            }
        }
        return isShared
    }
}

public extension URL {
    
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

extension UIImage {
    func rotateImage()-> UIImage?  {
        if (self.imageOrientation == UIImage.Orientation.up ) {
            return self
        }
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        let copy = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return copy
    }
}
