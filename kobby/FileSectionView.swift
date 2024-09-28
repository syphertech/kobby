import SwiftUI

struct FileSectionView: View {
    let fileName: String
    let fileURL: URL?
    let isLoadingTranscription: Bool
    let isLoadingSave: Bool
    let isLoadingShare: Bool
    let transcription: String?
    
    var transcribeAction: () -> Void
    var shareAction: () -> Void

    var body: some View {
        VStack {
            if isLoadingTranscription || isLoadingSave || isLoadingShare {
                ProgressView() // Show ProgressView while processing
            } else if fileURL != nil {
                HStack(spacing: 20) {
                    Button(action: {
                        transcribeAction() // Trigger transcribe action
                    }) {
                        Image(systemName: "waveform.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(10)
                    }.buttonStyle(BorderlessButtonStyle())
                    .disabled(isLoadingTranscription) // Disable button while processing
                    HStack{
                        Text("#\(fileName.prefix(10))")
                            .padding(10)

                        if transcription != nil {
                            Image(systemName: "checkmark.seal.fill")
                                .resizable()
                                .frame(width: 10, height: 10)
                                .padding(10)
                        }
                    }
                   
                    
                    Spacer() // Add a Spacer to push the share button to the right
                    
                    Button(action: {
                        shareAction() // Trigger share action
                    }) {
                        Image(systemName: "arrow.up.circle.dotted")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(10)
                    }  .disabled(isLoadingShare).buttonStyle(BorderlessButtonStyle())
                }
                
                
                if let transcription = transcription {
                    Text(transcription)
                        .font(.subheadline)
                        .padding(20)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 70)  // Take max width and a fixed height
        .background(Color.purple)  // Apply background before clipping
        .clipShape(RoundedRectangle(cornerRadius: 20))  // Rounded corners
        .shadow(radius: 5)  // Optional: Add shadow for a better look
        .foregroundStyle(.white)  // Text and image color
        .padding()
    }
}
