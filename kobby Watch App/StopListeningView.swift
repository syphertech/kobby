//
//  stoplistening.swift
//  kobe
//
//  Created by Maxwell Anane on 8/26/24.
//

import SwiftUI

struct StopListeningView: View {
    @EnvironmentObject private var recorderContext: AudioRecorder
   
    var body: some View {
        VStack {
            SoundWaveAnimationView()
            VStack {
                Button(action: stopListening){
                
                    VStack {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundStyle(Color.red)
                            .frame(width: 25, height: 25)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                            .overlay({
                                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)).stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            }()
                                .foregroundColor(.red)
                                .frame(width: 30, height: 30, alignment: .center )
                                .opacity(0.3))
                        
                        Text("Stop Listening")
                            .font(.system(size: 15))
                            .foregroundColor(.red)
                            .foregroundStyle(.tint)
                            .padding(.top, 5)
                    }
                    
                } .buttonStyle(PlainButtonStyle())
            }
            
            
        }
       
        
    }
    func stopListening (){
        recorderContext.stopRecording()
    }
    
}


#Preview {
    StopListeningView()
}
