import SwiftUI


enum FilterOptions: String, CaseIterable, Identifiable {
    case all
    case completed
    case incomplete
}

extension FilterOptions {
    
    var id: String {
        rawValue
    }
    
    var displayName: String {
        rawValue.capitalized
    }
    
}

struct MainView: View {
    
    var body: some View {
        
        TabView {
            TodoListScreen().environmentObject(Model())
                .tabItem {
                    Image(systemName: "checkmark.square")
                    Text("To-do")
                }
            
            SendVideoScreen()
                .tabItem {
                    Image(systemName: "square.and.arrow.up")
                    Text("Upload Video")
                }
            
            ViewVideoScreen()
                .tabItem {
                    Image(systemName: "play")
                    Text("Watch Video")
                }
        }
    }
}


#Preview {
    MainView()
}
