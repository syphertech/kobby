////
////  savefile.swift
////  kobby
////
////  Created by Maxwell Anane on 9/4/24.
////
//
//import Foundation
//
//func saveFileToDisk( file: URL) {
//    // Get the URL for the Documents directory
//    guard let documentsDirectory = getDocumentsDirectory() else {
//        print("Unable to locate the Documents directory.")
//        return
//    }
//
//    // Create the full URL for the file to be saved
//    let fileURL = documentsDirectory.appendingPathComponent(fileName)
//
//    do {
//        // Write data to the file URL
//        try data.write(to: fileURL)
//        print("File saved successfully at \(fileURL.path)")
//    } catch {
//        print("Failed to save file: \(error.localizedDescription)")
//    }
//}
//
//func getDocumentsDirectory() -> URL? {
//    // Use FileManager to get the URL for the Documents directory
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    return paths.first
//}
//
