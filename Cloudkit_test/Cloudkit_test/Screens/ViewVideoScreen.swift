import SwiftUI
import CloudKit
import AVKit


struct ViewVideoScreen: View {
    
    // Create and own an instance of our ViewModel.
    @StateObject private var viewModel = VideoListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading Videos...")
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchVideos()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    // Display the list of videos.
                    List(viewModel.videoItems) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(item.title)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    Task {
                                        await viewModel.deleteVideo(item)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                }
                            }
                            
                            // Use the video player view you created earlier.
                            CloudVideoPlayer(videoAsset: item.videoAsset)
                                .frame(height: UIScreen.main.bounds.height) // Give the player a nice frame.
                                .cornerRadius(12)
                            

                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("My Videos")
            // The .task modifier automatically runs the fetch operation when the view appears.
            .task {
                await viewModel.fetchVideos()
            }
        }
    }
}


#Preview {
    ViewVideoScreen()
}
