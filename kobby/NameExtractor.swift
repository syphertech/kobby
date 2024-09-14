//
//  NameExtractor.swift
//  kobby
//
//  Created by Maxwell Anane on 9/8/24.
//

import Foundation

struct NameExtractor {
    
    // Static function to extract the names of other people
    static func extractOtherPersonsNames(from text: String, completion: @escaping ([String]?) -> Void) {
        // Fetch the user's first name from UserDefaults
        guard let currentUserName = UserDefaults.standard.string(forKey: "userFirstName") else {
            print("User name not found")
            completion(nil)
            return
        }

        // Your OpenAI API key
        let apiKey = "somekey"
        
        // Refined prompt for OpenAI to extract multiple names, excluding the user's name
        let prompt = """
        The following transcription contains a conversation between several people introducing themselves. One of them is named \(currentUserName). Your task is to extract the names of all other people introduced in this conversation, excluding \(currentUserName)'s name. If no other names are mentioned, return "Name not mentioned".
        Text: "\(text)"
        """

        // Request body for the OpenAI API
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini", // Replace with the appropriate model
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0
        ]

        // Prepare the URL for the OpenAI API
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Serialize request body to JSON
        do {
            let data = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = data
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            // Decode the response from OpenAI
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Clean up the response and extract names
                    let extractedNames = extractNames(from: content)
                    completion(extractedNames.isEmpty ? ["Name not mentioned"] : extractedNames)
                } else {
                    print("Invalid JSON format")
                    completion(nil)
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    // Helper function to extract names from the API's response
    private static func extractNames(from text: String) -> [String] {
        // Split the text and look for patterns that resemble names
        let words = text.split(separator: " ")
        
        var names = [String]()
        
        for word in words {
            // Simple heuristic: Look for capitalized words that could be names
            if word.first?.isUppercase == true {
                names.append(String(word))
            }
        }
        
        return names
    }
}

