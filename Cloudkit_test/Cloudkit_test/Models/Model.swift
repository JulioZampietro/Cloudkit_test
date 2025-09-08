// Handles addition, filtering, updating, and deletion of data to iCloud
// The View talks to the Model, that then persists data with CloudKit

import SwiftUI
import Foundation
import CloudKit


// @MainActor makes sure that this only runs on the main thread
// This is so that the compiler warns me whenever a background task tries to call the model
// I can then use "await" so that Swift handles the transition to the main thread
// It is common to use @MainActor for ObservableObjects because their task is to eventually update the UI
// This is considered by the author of the tutorial as an aggregate model, used for every action in the viewmodel
@MainActor
class Model: ObservableObject {
    
    private var db = CKContainer.default().privateCloudDatabase
    @Published private var tasksDictionary: [CKRecord.ID: TaskItem] = [:]
    
    var tasks: [TaskItem] {
        // Read-only TaskItem array that returns the first value of the tasks to the view
        tasksDictionary.values.compactMap{ $0 }
    }
    
    // Async means the function can be paused and resumed, essential for long-running tasks like network calls
    // Throw marks a function as failable, in the sense that it can fail and "throw" an error. Must be called with a "try"
    func addTask(taskItem:TaskItem) async throws {
        // Await can pause the function while the rest of the app keeps running, waiting for iCloud's servers to respond
        let record = try await db.save(taskItem.record)
        // The next lines are for the app to add new entries to the tasksDictionary
        guard let task = TaskItem(record: record) else { return }
        tasksDictionary[task.recordId!] = task
    }
    
    func updateTask(editedTaskItem: TaskItem) async throws {
        // Updates tasks. Used on TaskItemView to update on clicking
        
        // The dictionary is updated before the actual data because the db.save function has a bit of lag, given as
        // it is directly communicating with iCloud's servers. Updating the dictionary before passing db.save guarantees
        // that there is no perceived input lag when completing tasks
        tasksDictionary[editedTaskItem.recordId!]?.isCompleted = editedTaskItem.isCompleted
        
        do {
            let record = try await db.record(for: editedTaskItem.recordId!)
            record[TaskRecordKeys.isCompleted.rawValue] = editedTaskItem.isCompleted
            
            // Saves to the cloud
            try await db.save(record)
        } catch {
            // this is a place to throw an error to show the user that something has gone wrong in updating tasks
            tasksDictionary[editedTaskItem.recordId!]?.isCompleted = !editedTaskItem.isCompleted
        }
    }
    
    func deleteTask(taskItemToBeDeleted: TaskItem) async throws {
        
        tasksDictionary.removeValue(forKey: taskItemToBeDeleted.recordId!)
        
        do {
            let _ = try await db.deleteRecord(withID: taskItemToBeDeleted.recordId!)
        } catch {
            tasksDictionary[taskItemToBeDeleted.recordId!] = taskItemToBeDeleted
            print(error)
        }
    }
    
    // Populating tasks
    func populateTasks() async throws {
        
        // Predicate defines what parts are being selected; in this case, it selects all
        let query = CKQuery(recordType: TaskRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "dateAssigned", ascending: false)]
        // Fetches the results based on whatever the query defines
        let result = try await db.records(matching: query)
        // Get the matching records - ask Gemini what this line does
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        records.forEach {record in
            tasksDictionary[record.recordID] = TaskItem(record: record)
        }
    }
    
    func filterTaksItems(by filterOptions: FilterOptions) -> [TaskItem] {
        switch filterOptions {
        case .all:
            return tasks
        case .completed:
            return tasks.filter { $0.isCompleted }
        case .incomplete:
            return tasks.filter { !$0.isCompleted}
        }
    }
    
    func saveRecord(_ record: CKRecord) async throws {
        // This function would live inside your existing Model class.
        try await db.save(record)
    }
    
}


