//
//  VideoListViewModel.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 25/08/25.
//

import SwiftUI
import AVKit
import CloudKit


@MainActor
class VideoListViewModel: ObservableObject {
    
    // The array of videos that our view will display.
    // @Published means the view will automatically update when this changes.
    @Published var videoItems: [VideoItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = CKContainer.default().privateCloudDatabase

    /// Fetches all records of type "Videos" from the private CloudKit database.
    func fetchVideos() async {
        isLoading = true
        errorMessage = nil
        
        // A predicate with 'true' value fetches all records of the given type.
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Videos", predicate: predicate)
        
        // Add a sort descriptor to show the newest videos first.
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        do {
            // Fetch the records from CloudKit.
            let result = try await db.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            
            // Convert the CKRecords into our local VideoItem struct.
            // The 'compactMap' ensures that any records that fail to initialize are ignored.
            self.videoItems = records.compactMap(VideoItem.init)
            
        } catch {
            print("CloudKit Error: \(error.localizedDescription)")
            errorMessage = "Failed to fetch videos. Please check your connection."
        }
        
        isLoading = false
    }
    
    func deleteVideo(_ video: VideoItem) async {
        // Optimistically remove from local array first
        if let index = videoItems.firstIndex(where: { $0.id == video.id }) {
            videoItems.remove(at: index)
        }

        do {
            try await db.deleteRecord(withID: video.id)
            print("Video deleted successfully: \(video.title)")
        } catch {
            print("Failed to delete video: \(error.localizedDescription)")
            // Optionally, re-add the video locally if deletion fails
            videoItems.append(video)
        }
    }
}
