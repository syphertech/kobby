import Foundation
import AVFoundation

struct AudioFileManager {
    
    static func transcribeAudio(fileURL: URL, completion: @escaping ([String]?, Error?) -> Void) {
        let boundary = UUID().uuidString
        let apiKey = UserDefaults.standard.string(forKey: "bearerToken") ?? ""
        var request = createRequest(urlString: "https://us-central1-kobby-435019.cloudfunctions.net/transcribe", jwtToken: apiKey, boundary: boundary)
        request.httpBody = createMultipartBody(fileURL: fileURL, boundary: boundary)
        let userName = UserDefaults.standard.bool(forKey: "fisrtName");
        // Print the request headers to debug
        if let headers = request.allHTTPHeaderFields {
            print("Request Headers: \(headers)")
        } else {
            print("No headers are set in the request.")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "AudioFileManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            // Print the raw response to the console
            if let rawResponse = String(data: data, encoding: .utf8) {
                print("Raw Response: \(rawResponse)")
            } else {
                print("Failed to convert data to string.")
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   
                   var text = jsonResponse["name"] as? [String]  {
                    text = text.filter{ $0 != "\(userName)"}
                    completion(text, nil)
                } else {
                    completion(nil, NSError(domain: "AudioFileManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"]))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }

    static func saveAudioFileToDisk(fileURL: URL) throws -> URL {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "AudioFileManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unable to locate the Documents directory."])
        }

        let destinationURL = documentsDirectory.appendingPathComponent(fileURL.lastPathComponent)

        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }

        try FileManager.default.copyItem(at: fileURL, to: destinationURL)
        return destinationURL
    }

    private static func createRequest(urlString: String, jwtToken: String, boundary: String) -> URLRequest {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let authorizationValue = "Bearer \(jwtToken)"
               request.setValue(authorizationValue, forHTTPHeaderField: "Authorization")
               request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
               
        // Set headers correctly
        
        // Debug print statements for headers
        print("Authorization Header: Bearer \(jwtToken)")
        print("Content-Type Header: multipart/form-data; boundary=\(boundary)")
        if let headers = request.allHTTPHeaderFields {
            print("creattion level Request Headers: \(headers)")
        } else {
            print("No headers are set in the request.")
        }
        return request
    }

    private static func createMultipartBody(fileURL: URL, boundary: String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        
        if let audioData = try? Data(contentsOf: fileURL) {
            body.append(boundaryPrefix.data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
            body.append(audioData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    
    
    
}
