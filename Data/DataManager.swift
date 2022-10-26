//
//  DataManager.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//


import CoreData
import Foundation

final class PersistenceProvider {
    enum StoreType {
        case inMemory, persisted
    }

    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: PersistenceProvider.self)
        guard let url = bundle.url(forResource: "Data", withExtension: "momd") else {
            fatalError("Failed to locate momd file for Checklist")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for Checklist")
        }
        return model
    }()

    var persistentContainer: NSPersistentContainer
    var context: NSManagedObjectContext { persistentContainer.viewContext }

    var documentDir: URL {
        let documentDir = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
        return documentDir!
    }

    static let `default`: PersistenceProvider = PersistenceProvider()
    init(storeType: StoreType = .persisted) {
        persistentContainer = NSPersistentContainer(name: "Data", managedObjectModel: Self.managedObjectModel)

        if storeType == .inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        persistentContainer.loadPersistentStores { _, error in
            self.context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
            self.context.automaticallyMergesChangesFromParent = true

            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }

    }
    

}

extension PersistenceProvider {
    
     
     var allTasks: [Task]{
         get {
             let c = getTasks()
             return c
         }
     }
     
    func clearDB() {
        // List of multiple objects to delete
        let colors: [Task] = getTasks()

        // Get a reference to a managed object context
        let context = persistentContainer.viewContext

        // Delete multiple objects
        for color in colors {
            delete(color)
        }

        // Save the deletions to the persistent store
        try? context.save()
    }
   
    func getFilteredTasks(filterDate: Date) -> [Task] {
        let fetchRequest: NSFetchRequest = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(createdAt >= %@) AND (createdAt <= %@)", filterDate as CVarArg, filterDate.dateAtEndOf(.day) as CVarArg)
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            keyPath: \Task.order,
            ascending: false)]
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            return []
        }
    }

    func getTasks() -> [Task] {
        let fetchRequest: NSFetchRequest = Task.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(
            keyPath: \Task.createdAt,
            ascending: false)]
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch {
            return []
        }
    }

   
    func delete(_ item: Task) {
        context.delete(item)
        try? context.save()
    }
}
