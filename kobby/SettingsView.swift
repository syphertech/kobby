//
//  SettingsView.swift
//  kobby
//
//  Created by Maxwell Anane on 8/31/24.
//
import SwiftUI
import Security

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Page Content")
            //
            //  settings.swift
            //  kobe
            //
            //  Created by Maxwell Anane on 8/27/24.
            //
            
            
            
            
            
            
        }
        .navigationTitle("Settings") // Set the title for the settings page
        .navigationBarTitleDisplayMode(.inline) // Optional: set display mode to inline
    }
        private   func deleteKeychainData(for service: String) {
               
               UserDefaults.standard.removeObject(forKey: "userToken")
               UserDefaults.standard.synchronize()
               let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                           kSecAttrService as String: service]
               let status = SecItemDelete(query as CFDictionary)
               if status == errSecSuccess {
                   print("Successfully deleted keychain item.")
               } else {
                   print("Failed to delete keychain item with status: \(status)")
               }
           }

    }
    
extension Color {
    // Light Theme Colors
    static let lightBackground = Color(red: 227 / 255.0, green: 242 / 255.0, blue: 253 / 255.0)
    static let lightPrimaryText = Color(red: 42 / 255.0, green: 26 / 255.0, blue: 96 / 255.0)
    static let lightSecondaryText = Color(red: 142 / 255.0, green: 153 / 255.0, blue: 243 / 255.0)
    static let lightAccent = Color(red: 0 / 255.0, green: 240 / 255.0, blue: 216 / 255.0)
    static let lightBorder = Color(red: 224 / 255.0, green: 224 / 255.0, blue: 224 / 255.0)
    
    // Dark Theme Colors
    static let darkBackground = Color(red: 42 / 255.0, green: 26 / 255.0, blue: 96 / 255.0)
    static let darkPrimaryText = Color(red: 229 / 255.0, green: 229 / 255.0, blue: 229 / 255.0)
    static let darkSecondaryText = Color(red: 170 / 255.0, green: 170 / 255.0, blue: 170 / 255.0)
    static let darkAccent = Color(red: 0 / 255.0, green: 240 / 255.0, blue: 216 / 255.0)
    static let darkBorder = Color(red: 142 / 255.0, green: 153 / 255.0, blue: 243 / 255.0)
}
