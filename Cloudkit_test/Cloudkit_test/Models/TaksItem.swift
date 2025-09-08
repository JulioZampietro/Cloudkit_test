import Foundation
import CloudKit


// Saves a custom Swift data type to CloudKit

// Creates custom official labels for data fields to save to iCloud. Used to avoid typos in the extension that
// would not be recognized as errors by the compiler
enum TaskRecordKeys: String {
    case type = "TaskItem"
    case title
    case dateAssigned
    case isCompleted
}

struct TaskItem {
    
    // Unique key for a particular task, created automatically when a particular task is stored in the database
    // This is necessary to save to iCloud; it does not save TaskItem in its "natural" form
    var recordId: CKRecord.ID?
    // Characteristics of the task
    let title: String
    let dateAssigned: Date
    var isCompleted: Bool = false
    
}

// Necessary for the tasksDictionary in the Model file to work
extension TaskItem {
    init?(record: CKRecord) {
        guard let title = record[TaskRecordKeys.title.rawValue] as? String,
              let datesAssigned = record[TaskRecordKeys.dateAssigned.rawValue] as? Date,
              let isCompleted = record[TaskRecordKeys.isCompleted.rawValue] as? Bool else {
            return nil
        }
        
        // The 'record' below refers to the 'record' passed in within the init above. It is a local variable
        self.init(recordId: record.recordID, title: title, dateAssigned: datesAssigned, isCompleted: isCompleted)
    }
}

// Responsible for translating the TaskItem to a CKRecord that iCloud can understand
// CKRecord is freshly created every time, it is a piece of code based on TaskItem's current properties
extension TaskItem {
    var record: CKRecord {
        let record = CKRecord(recordType: TaskRecordKeys.type.rawValue)
        record[TaskRecordKeys.title.rawValue] = title
        record[TaskRecordKeys.dateAssigned.rawValue] = dateAssigned
        record[TaskRecordKeys.isCompleted.rawValue] = isCompleted
        return record
    }
    
}

