//
//  kobbyApp.swift
//  kobby Watch App
//
//  Created by Maxwell Anane on 8/27/24.
//

import SwiftUI

@main
struct kobby_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AudioRecorder())

        }
    }
}
