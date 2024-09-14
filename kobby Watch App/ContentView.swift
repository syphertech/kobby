//
//  ContentView.swift
//  kobby Watch App
//
//  Created by Maxwell Anane on 8/26/24.
//

import AVFoundation
import SwiftUI

struct ContentView: View {

    @EnvironmentObject private var recorderContext: AudioRecorder
    @Environment(\.colorScheme) var colorScheme
    var body: some View {

        NavigationStack {
            VStack {
                if recorderContext.isRecording {
                    StopListeningView()
                } else {
                    StartListeningView()
                }

            }
            
        }
    }

}

#Preview {
    ContentView().environmentObject(AudioRecorder())
}
