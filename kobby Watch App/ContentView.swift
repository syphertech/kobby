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
            .alert(isPresented: $recorderContext.ShowPermissionNeededAlert
            ){
                Alert(title: Text("Permission Needed"),
                      message:
                        Text("To use the microphone, please go to Settings > Privacy > Microphone and enable it.")
                )
                
            }
        }
        
        
    }
}

#Preview {
    ContentView().environmentObject(AudioRecorder())
}
