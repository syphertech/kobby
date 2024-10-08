import AVFoundation
import WatchConnectivity
import SwiftUI

class AudioRecorder: NSObject, ObservableObject, WCSessionDelegate {

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?  // Add AVAudioPlayer for playback
    @Published var isRecording = false
    @Published var ShowPermissionNeededAlert = false
    private var fileURL: URL?

    override init() {
        super.init()
        setupRecorder()

        // Setup Watch Connectivity session
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    // Request microphone permission and set up audio session
    private func setupRecorder() {
        AVAudioApplication.requestRecordPermission{ granted in
            if granted {
               
                do {
                    try AVAudioSession.sharedInstance().setCategory(
                        .playAndRecord, mode: .spokenAudio)
                    try AVAudioSession.sharedInstance().setActive(
                        true, options: .notifyOthersOnDeactivation)
                    print("Audio session is set and active")
                } catch {
                    print("Failed to set up audio session: \(error.localizedDescription)")
                }
            } else {
                print("Microphone permission not granted")
                self.ShowPermissionNeededAlert = true
            }
        }
    }

    // Start recording audio
    func startRecording() {
        let formattedDate = UUID().uuidString
        let audioFilename = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(formattedDate)recording.m4a")
        self.fileURL = audioFilename
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            isRecording = true
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }

    // Stop recording audio
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        deactivateAudioSession()
        sendRecordingToiPhone()
        
        // Play the recorded file after stopping
//        if let fileURL = fileURL {
//            playRecording(fileURL: fileURL)
//        }
    }

    private func playRecording(fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            print("Playing back the recording from \(fileURL.path)")
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    private func sendRecordingToiPhone() {
        guard let fileURL = fileURL else { return }
        guard WCSession.default.isReachable else {
            print("iPhone not reachable for file transfer.")
            return
        }
        WCSession.default.transferFile(fileURL, metadata: nil)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            print("File transfer failed: \(error.localizedDescription)")
        } else {
            do {
                try FileManager.default.removeItem(at: fileTransfer.file.fileURL)
                print("File successfully transferred and deleted from watch.")
            } catch {
                print("Failed to delete file from watch: \(error.localizedDescription)")
            }
        }
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    // Handle audio recorder finish
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording()
        }
    }
}
