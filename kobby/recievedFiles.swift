import SwiftUI
import CoreData

struct RecievedFiles: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: ReceivedFile.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ReceivedFile.dateReceived, ascending: false)]
    ) private var receivedFiles: FetchedResults<ReceivedFile>
    
    @Environment(\.colorScheme) var colorScheme
    @State private var transcriptionResults: [URL: String] = [:]
    @State private var isLoadingTranscription: [URL: Bool] = [:]
    @State private var isLoadingSave: [URL: Bool] = [:]
    @State private var isLoadingShare: [URL: Bool] = [:]
    @State private var extractedPersonNames: [URL: [String]] = [:]  // Updated to store multiple names
    @State private var showShareSheet = false
    @State private var fileToShare: URL?

    var body: some View {
        NavigationStack {
            let validFiles = receivedFiles.filter { fileExists(for: $0) }

            if validFiles.isEmpty {
                ContentUnavailableView("No new recordings", systemImage: "mic", description: Text("You haven't met anyone new recently"))
                    .symbolVariant(.slash)
            } else {
                List(validFiles, id: \.self) { file in
                    if let fileURL = fileURL(for: file) {
                        FileSectionView(
                            fileName: file.fileName ?? "Unknown",
                            fileURL: fileURL,
                            isLoadingTranscription: isLoadingTranscription[fileURL] == true,
                            isLoadingSave: isLoadingSave[fileURL] == true,
                            isLoadingShare: isLoadingShare[fileURL] == true,
                            transcription: transcriptionResults[fileURL],
                            transcribeAction: {
                                transcribeAudio(fileURL: fileURL)
                            },
                            shareAction: {
                                shareFile(fileURL: fileURL)
                            }
                        )
                        .listRowSeparator(.hidden)

                        // Display extracted names if available
                        if let names = extractedPersonNames[fileURL], !names.isEmpty {
                            Text("People you met: \(names.joined(separator: ", "))")
                                .font(.headline)
                                .padding(.leading, 10)
                        }
                    } else {
                        Text("Invalid file URL")
                    }
                }
                .navigationTitle("Received Files")
                .background(.clear)
                .sheet(isPresented: $showShareSheet) {
                    if let fileToShare = fileToShare {
                        ActivityViewController(activityItems: [fileToShare])
                    }
                }
            }
        }
    }

    private func fileURL(for file: ReceivedFile) -> URL? {
        guard let filePath = file.filePath else { return nil }
        return URL(fileURLWithPath: filePath)
    }

    private func fileExists(for file: ReceivedFile) -> Bool {
        guard let fileURL = fileURL(for: file) else { return false }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    func saveData(names: [String]) {
        for name in names {
            if name == "unknown" { continue }
            let newEntry = People(context: viewContext)
            newEntry.id = UUID()
            newEntry.name = name
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd/HH/mmss"
            let formattedDate = formatter.string(from: Date())
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
    
    private func transcribeAudio(fileURL: URL) {
        guard let apiKey = AudioFileManager.fetchOpenAIAPIKey() else {
            print("OpenAI API Key not found.")
            return
        }

        isLoadingTranscription[fileURL] = true

        AudioFileManager.transcribeAudio(fileURL: fileURL, apiKey: apiKey) { text, error in
            DispatchQueue.main.async {
                self.isLoadingTranscription[fileURL] = false

                if let error = error {
                    print("Error during transcription: \(error.localizedDescription)")
                    return
                }
                if let text = text {
                    self.transcriptionResults[fileURL] = text

                    // Extract the names of the new people using the updated NameExtractor
                    NameExtractor.extractOtherPersonsNames(from: text) { names in
                        DispatchQueue.main.async {
                            if let peopleNames = names, !peopleNames.isEmpty {
                                self.extractedPersonNames[fileURL] = peopleNames
                                // Save the extracted names into Core Data
                                saveData(names: peopleNames)
                            } else {
                                self.extractedPersonNames[fileURL] = ["Name not found"]
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func shareFile(fileURL: URL) {
        self.fileToShare = fileURL
        self.showShareSheet = true
    }
}
