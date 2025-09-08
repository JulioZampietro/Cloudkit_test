//
//  TodoListScreen.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 21/08/25.
//

import SwiftUI


struct TodoListScreen: View {
    
    @EnvironmentObject private var model: Model
    @State private var taskTitle: String = ""
    @State private var filterOption: FilterOptions = .all
    
    var body: some View {
        
        VStack {
            TextField("Enter task", text: $taskTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    // add validation TODO
                    let taskItem = TaskItem(title: taskTitle, dateAssigned: Date())
                    Task {
                        try await model.addTask(taskItem: taskItem)
                    }
                }
            
            // Setting the filtering menu
            Picker("Select", selection: $filterOption) {
                ForEach(FilterOptions.allCases) { option in
                    Text(option.displayName).tag(option)
                }
            }.pickerStyle(.segmented)
            
            // Have to make sure tasks are identifiable, or at least include the correct id
            TaskListView(taskItems: model.filterTaksItems(by: filterOption))
            
            Spacer ()
        }
        .task {
            do {
                try await model.populateTasks()
            } catch {
                print(error)
            }
        }
        .padding()
    }
}


struct TodoListScreen_Previews: PreviewProvider {
    static var previews: some View {
        // Injects model into the preview
        TodoListScreen().environmentObject(Model())
    }
}
