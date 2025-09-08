//
//  Movie.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 25/08/25.
//

import SwiftUI
import AVKit

struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            // Create a unique filename using a UUID to avoid conflicts.
            let fileName = UUID().uuidString + ".mov"
            let copy = URL.temporaryDirectory.appending(path: fileName)
            
            // If a file with this name already exists, remove it before copying.
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            
            // Copy the received file to the new unique URL.
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}
