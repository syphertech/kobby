//
//  nameProcessor.swift
//  kobby
//
//  Created by Maxwell Anane on 9/2/24.
//

import Speech
import Foundation
import SwiftUICore
import CoreData

class NameProcessor :NSObject, ObservableObject {
    private var viewContext: NSManagedObjectContext
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionTask: SFSpeechRecognitionTask?
    @Published var recognizedText:[String: String] = [:]
    
    init(viewContext: NSManagedObjectContext) {
           self.viewContext = viewContext
           super.init()
           requestPermissions()
       }
    func requestPermissions() {
           SFSpeechRecognizer.requestAuthorization { authStatus in
               switch authStatus {
               case .authorized:
                   print("Speech recognition authorized")
               case .denied:
                   print("Speech recognition authorization denied")
               case .restricted:
                   print("Speech recognition restricted")
               case .notDetermined:
                   print("Speech recognition not determined")
               @unknown default:
                   print("Unknown speech recognition authorization status")
               }
           }
       }
    
   
    func recognizeSpeech(from fileURL: URL) {
           // Cancel previous recognition task if it's running
        print("running recognition task")
           recognitionTask?.cancel()
           recognitionTask = nil
           
           // Create a recognition request for the audio file
           let recognitionRequest = SFSpeechURLRecognitionRequest(url: fileURL)
           
           recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
               if let result = result {
                   DispatchQueue.main.async {
                      let name  = result.bestTranscription.formattedString
                       self.saveData(name: name)
                       self.recognizedText[fileURL.lastPathComponent] = name
                       print("procssed message transcription")
                       print(name)
                   }
               }
               
               if let error = error {
                   print("Speech recognition error: \(error.localizedDescription)")
               }
           }
       }
    
   
     func saveData(name: String) {
        let newEntry = People(context: viewContext)
        newEntry.id = UUID()
        newEntry.name = name
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd/HH/mmss"
        let formattedDate = formatter.string(from: Date())
        print(formattedDate)
        newEntry.timestamp = formattedDate
        newEntry.location = ""
        newEntry.notes = "No notes"
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving new person: \(error.localizedDescription)")
        }
    }
}
