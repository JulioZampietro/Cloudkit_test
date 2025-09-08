//
//  VideoItem.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 25/08/25.
//

import SwiftUI
import AVKit
import CloudKit


struct VideoItem: Identifiable {
    let id: CKRecord.ID // Use the record's ID for Identifiable conformance
    let title: String
    let videoAsset: CKAsset
    
    init?(record: CKRecord) {
        guard let title = record["title"] as? String,
              let videoAsset = record["videoFile"] as? CKAsset else {
            return nil
        }
        self.id = record.recordID
        self.title = title
        self.videoAsset = videoAsset
    }
}

