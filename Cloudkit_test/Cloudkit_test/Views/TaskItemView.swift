//
//  TaskItemView.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 20/08/25.
//

import SwiftUI


struct TaskItemView: View {
    
    // Constant, because TaskItemView should not be able to change data
    let taskItem: TaskItem
    // Used to send the update up the hierarchy into TaskListView, the parent view that owns the tasks
    let onUpdate: (TaskItem) -> Void
    
    var body: some View {
        
        HStack {
            Text(taskItem.title)
            Spacer()
            Image(systemName: taskItem.isCompleted ? "checkmark.square" : "square")
                .onTapGesture {
                    var taskItemToUpdate = taskItem
                    taskItemToUpdate.isCompleted = !taskItemToUpdate.isCompleted
                    // Sends the updated copy of taskItem to the parent
                    onUpdate(taskItemToUpdate)
                }
        }
        .padding()
        
    }
}

struct TaskItemView_Previews: PreviewProvider {
    static var previews: some View {
        // The { _ in } is only used so that the preview renders without needing a real parent to handle data updates
        TaskItemView(taskItem: TaskItem(title: "Mow the lawn", dateAssigned: Date()), onUpdate: { _ in })
    }
}
