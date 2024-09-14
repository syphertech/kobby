import SwiftUI
import AuthenticationServices

@MainActor
struct ContentView: View {
    @State private var isLoggedIn: Bool = false

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                HomeView()
                // Navigate to the next page if authenticated
            } else {
                // Show the Sign In with Apple button
                SignView(isLoggedIn: $isLoggedIn)
            }
        }
        .onAppear {
            checkLoginStatus()
        }
    }
    
    private func checkLoginStatus() {
        // Check if user is already logged in by looking up UserDefaults
        if let _ = UserDefaults.standard.string(forKey: "userId") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
}

#Preview {
    ContentView()
}
