import SwiftUI
import WatchConnectivity
import CoreData
import AVFoundation

enum AudioReceiverError: Error {
    case fileMoveFailed(String)
    case coreDataSaveFailed(String)
    case audioProcessingFailed(String)
}

class AudioReceiver: NSObject, ObservableObject, WCSessionDelegate {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session is inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("Session is deactivated")
    }

    // WCSessionDelegate method to receive file
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        do {
            // Try saving the file
            let savedURL = try saveReceivedFile(file: file)
            
            // Apply low-pass filter to the saved audio file
            //let filteredFileURL = try applyLowPassFilterToAudio(at: savedURL)
            
            // If successful, save file metadata to Core Data
            try saveReceivedFileToCoreData(fileName: savedURL.lastPathComponent, filePath: savedURL.path)
            
        } catch {
            // Handle the error appropriately
            handleError(error)
        }
    }

    // Save the received file to the Documents directory with error handling
    private func saveReceivedFile(file: WCSessionFile) throws -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(file.fileURL.lastPathComponent)

        do {
            try fileManager.moveItem(at: file.fileURL, to: destinationURL)
            print("File successfully moved to: \(destinationURL.path)")
            return destinationURL
        } catch {
            print("Error moving file: \(error.localizedDescription)")
            throw AudioReceiverError.fileMoveFailed("Failed to move file to: \(destinationURL.path)")
        }
    }

    // Apply low-pass filter to the audio file and save it as a new file
    private func applyLowPassFilterToAudio(at inputFileURL: URL) throws -> URL {
        let audioFile = try AVAudioFile(forReading: inputFileURL)
        let audioEngine = AVAudioEngine()
        let audioFilePlayer = AVAudioPlayerNode()
        let lowPassFilter = AVAudioUnitEQ(numberOfBands: 1)
        
        // Configure the low-pass filter
        let band = lowPassFilter.bands.first!
        band.filterType = .lowPass
        band.frequency = 3000.0  // Cutoff frequency in Hz
        band.bandwidth = 0.5     // Q factor
        
        audioEngine.attach(audioFilePlayer)
        audioEngine.attach(lowPassFilter)
        
        // Connect the nodes
        audioEngine.connect(audioFilePlayer, to: lowPassFilter, format: audioFile.processingFormat)
        audioEngine.connect(lowPassFilter, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        
        // Create a URL for the filtered audio file
        let filteredFileURL = inputFileURL.deletingLastPathComponent().appendingPathComponent("filtered_" + inputFileURL.lastPathComponent)
        
        let outputFile = try AVAudioFile(forWriting: filteredFileURL, settings: audioFile.fileFormat.settings)
        
        // Install a tap on the mainMixerNode to capture the processed audio
        audioEngine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: audioFile.processingFormat) { (buffer, _) in
            do {
                try outputFile.write(from: buffer)
            } catch {
                print("Error writing filtered audio to file: \(error.localizedDescription)")
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Play and process the file
        audioFilePlayer.scheduleFile(audioFile, at: nil) {
            audioEngine.stop()
            audioEngine.mainMixerNode.removeTap(onBus: 0)
        }
        audioFilePlayer.play()

        // Wait for the duration of the audio file to ensure processing completes
        let duration = Double(audioFile.length) / audioFile.fileFormat.sampleRate

               // Wait for the duration of the audio file to ensure processing completes
          usleep(UInt32(duration * 1_000_000))
        
        // Return the URL of the filtered audio file
        return filteredFileURL
    }

    // Save received file metadata (file name, path) to Core Data with error handling
    private func saveReceivedFileToCoreData(fileName: String, filePath: String) throws {
        let newFile = ReceivedFile(context: context)
        newFile.fileName = fileName
        newFile.filePath = filePath
        newFile.dateReceived = Date().formatted()

        do {
            try context.save()
            print("File metadata saved to Core Data")
        } catch {
            print("Error saving to Core Data: \(error.localizedDescription)")
            throw AudioReceiverError.coreDataSaveFailed("Failed to save file metadata to Core Data for file: \(fileName)")
        }
    }

    // General error handler for file and Core Data errors
    private func handleError(_ error: Error) {
        switch error {
        case AudioReceiverError.fileMoveFailed(let message):
            print("File Move Error: \(message)")
        case AudioReceiverError.coreDataSaveFailed(let message):
            print("Core Data Save Error: \(message)")
        case AudioReceiverError.audioProcessingFailed(let message):
            print("Audio Processing Error: \(message)")
        default:
            print("Unknown error: \(error.localizedDescription)")
        }
    }
}
