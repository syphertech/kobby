import CoreData

func deleteObject(uuid: UUID, entityName: String) -> Bool {
    let viewContext = DataController.shared.container.viewContext
    
    // Create a fetch request for the specified entity with the given UUID
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    fetchRequest.fetchLimit = 1  // Limit to one result
    
    // Perform the fetch request and delete the object if found
    do {
        if let objectToDelete = try viewContext.fetch(fetchRequest).first as? NSManagedObject {
            viewContext.delete(objectToDelete)
            try viewContext.save()
            return true  // Successfully deleted
        }
    } catch {
        print("Error deleting object: \(error.localizedDescription)")
    }
    
    return false  // Deletion failed
}
