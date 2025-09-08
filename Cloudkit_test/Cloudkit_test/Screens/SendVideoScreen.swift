//
//  VideoScreen.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 21/08/25.
//

import SwiftUI
import PhotosUI
import CloudKit


// A view that allows a user to select a video and upload it to CloudKit.
struct SendVideoScreen: View {
    
    @EnvironmentObject private var model: Model
    
    // State to hold the selected item from the PhotosPicker.
    @State private var selectedItem: PhotosPickerItem?
    
    // State to show progress or completion status to the user.
    @State private var uploadStatus: String = "Tap to select a video"
    @State private var isUploading = false

    var body: some View {
        VStack(spacing: 20) {
            Text("CloudKit Video Uploader")
                .font(.largeTitle)

            // The PhotosPicker is the modern way to let users select media.
            // We filter it to only show videos.
            PhotosPicker(selection: $selectedItem, matching: .videos) {
                Label("Select Video", systemImage: "video.fill")
            }
            .buttonStyle(.borderedProminent)
            .disabled(isUploading) // Disable the button while uploading.

            if isUploading {
                ProgressView()
                Text("Uploading...")
            } else {
                Text(uploadStatus)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        // This .onChange modifier triggers when the user selects a video.
        .onChange(of: selectedItem) { newItem in
            guard let item = newItem else { return }
            
            // Start a new Task to handle the asynchronous work.
            Task {
                await uploadVideo(from: item)
            }
        }
    }
    
    /// Handles the entire process of loading and uploading the selected video.
    private func uploadVideo(from item: PhotosPickerItem) async {
        await MainActor.run {
            isUploading = true
            uploadStatus = "Preparing video..."
        }
        
        do {
            // 1. Load the video data and get a temporary local URL.
            guard let videoURL = await getURLForPickerItem(item) else {
                throw NSError(domain: "VideoUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create a local file for the video."])
            }
            
            // 2. Create the CKAsset from the local file URL.
            let videoAsset = CKAsset(fileURL: videoURL)
            
            // 3. Create a CKRecord and attach the asset.
            let newRecord = CKRecord(recordType: "Videos") // Use your desired record type
            newRecord["videoFile"] = videoAsset
            newRecord["title"] = "A New Video" // Add any other metadata
            
            // 4. Save the record to CloudKit using your model.
            try await model.saveRecord(newRecord)
            
            await MainActor.run {
                uploadStatus = "Upload complete! 🎉"
                isUploading = false
            }
            
        } catch {
            print("Detailed CloudKit Error: \(error)")
            
            await MainActor.run {
                uploadStatus = "Upload failed: \(error.localizedDescription)"
                isUploading = false
            }
        }
    }
    
    /// Converts a PhotosPickerItem into a temporary local file URL.
    private func getURLForPickerItem(_ item: PhotosPickerItem) async -> URL? {
        // Ask the item to load its transferable representation.
        guard let movie = try? await item.loadTransferable(type: Movie.self) else {
            return nil
        }
        // The Movie struct from PhotosUI has the URL we need.
        return movie.url
    }
}


struct SendVideoScreen_Previews: PreviewProvider {
    static var previews: some View {
        SendVideoScreen()
    }
}

