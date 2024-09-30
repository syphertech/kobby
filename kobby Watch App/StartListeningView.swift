//
//  StartListening.swift
//  kobby
//
//  Created by Maxwell Anane on 8/26/24.
//
import SwiftUI


struct StartListeningView    : View {
  
    @EnvironmentObject private var recorderContext: AudioRecorder
    var body: some View {
        Button(action: startListening){
            VStack {
                Image("StartListeningIcon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay({
                        Circle().stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    }()
                        .foregroundColor(.purple)
                        .frame(width:100, height: 80)
                        .opacity(0.3))
                Text("Start Listening")
                    .font(.system(size: 15))
                    .foregroundColor(.cyan)
                    .foregroundStyle(.tint)
                    .padding(.top, 10)
            }
            
        } .buttonStyle(PlainButtonStyle())

        
        
        
        
    }
    

    func  startListening(){
        recorderContext.startRecording()
    }

}
#Preview {
    StartListeningView().environmentObject(AudioRecorder())
}
