//
//  TaskListView.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 20/08/25.
//

import SwiftUI

struct TaskListView: View {
    
    // So that filtering works, taking the items
    let taskItems: [TaskItem]
    // Using EnvironmentObject to get access to the model, injecting it
    @EnvironmentObject private var model: Model
    
    var body: some View {
        List {
            ForEach(taskItems, id: \.recordId) { taskItem in
                TaskItemView(taskItem: taskItem, onUpdate: { editedTask in
                    Task {
                        do {
                            try await model.updateTask(editedTaskItem: editedTask)
                        } catch {
                            print(error)
                        }
                    }
                })
            }.onDelete { indexSet in
                // .onDelete is a native modifier that adds swipe-to-delete functions to a ForEach loop within a List
                
                // Safely obtains the index of the swiped item
                guard let index = indexSet.map({ $0 }).last else {
                    return
                }
                
                // Selects the swiped item within the model
                let taskItem = model.tasks[index]
                Task {
                    do {
                        try await model.deleteTask(taskItemToBeDeleted: taskItem)
                    } catch {
                        print(error)
                    }
                }
                
            }
        }
        
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(taskItems: []).environmentObject(Model())
    }
}
