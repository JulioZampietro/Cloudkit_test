//
//  Cloudkit_testApp.swift
//  Cloudkit_test
//
//  Created by Júlio Zampietro on 18/08/25.
//

import SwiftUI

@main
struct Cloudkit_testApp: App {
    @StateObject private var model = Model()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(model)
        }
    }
}
