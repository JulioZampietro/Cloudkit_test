//
//  CloudVideoView.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 25/08/25.
//

import SwiftUI
import AVKit
import CloudKit


struct CloudVideoPlayer: View {
    
    let videoAsset: CKAsset
    @State private var player: AVPlayer?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if let player = player {
                VideoPlayer(player: player)
            } else if let errorMessage = errorMessage {
                // Display an error message if the file is missing
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await loadVideoPlayer()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    private func loadVideoPlayer() async {
        guard let fileURL = videoAsset.fileURL else {
            await MainActor.run { errorMessage = "Error: Video asset has no file URL." }
            return
        }
        
        do {
            // Load data from the CKAsset's fileURL
            let data = try Data(contentsOf: fileURL)
            
            // Write to a temporary local file
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
            try data.write(to: tempURL)
            
            print("Success: Video copied to tempURL \(tempURL)")
            await MainActor.run {
                player = AVPlayer(url: tempURL)
            }
        } catch {
            print("Error loading video: \(error.localizedDescription)")
            await MainActor.run { errorMessage = "Video could not be loaded." }
        }
    }
}

