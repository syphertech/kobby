import SwiftUI
import WatchConnectivity
import CoreData

enum AudioReceiverError: Error {
    case fileMoveFailed(String)
    case coreDataSaveFailed(String)
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
            
            // If successful, save file metadata to Core Data
            try saveReceivedFileToCoreData(fileName: file.fileURL.lastPathComponent, filePath: savedURL.path)
            
            
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
            // Optionally: Show an alert to the user
        case AudioReceiverError.coreDataSaveFailed(let message):
            print("Core Data Save Error: \(message)")
            // Optionally: Show an alert to the user
        default:
            print("Unknown error: \(error.localizedDescription)")
            // Optionally: Show an alert to the user
        }
    }
}
