import SwiftUI
import FirebaseAuth
import AuthenticationServices


struct SignView: View {
    @Binding var isLoggedIn: Bool

    @Environment(\.colorScheme) var colorScheme
    @State private var currentNonce: String?
    var body: some View {
        ZStack {
            VideoPlayerView(videoName: "friends", videoType: "mp4")
                .edgesIgnoringSafeArea(.all)
            VStack {
                Image("icon")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .padding(.bottom, 5)

                Text("Welcome to Kobby")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                    .fontWeight(.heavy)

                Spacer()

                VStack {
                    Text("Never forget a face with the Kobby app—your memory's new best friend.")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                    
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            // Handle successful authentication.
                            handleAuthorization(authResults)
                        case .failure(let error):
                            // Handle error.
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                    .signInWithAppleButtonStyle(.black)
                }
                .padding(50)
            }
        }
    }

//    private func handleAuthorization(_ authResults: ASAuthorization) {
//        // Extract the authorization details from the result.
//        if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
//            // Save user details in UserDefaults
//            UserDefaults.standard.set(credential.user, forKey: "userId")
//            UserDefaults.standard.set(credential.email, forKey: "email")
//            UserDefaults.standard.set(credential.fullName?.givenName, forKey: "firstName")
//            UserDefaults.standard.set(credential.fullName?.familyName, forKey: "lastName")
//
//            print("User name: \(String(describing: credential.fullName?.givenName))")
//
//            // Set isLoggedIn to true after saving
//            isLoggedIn = true
//        }
//    }

    private func onRequest(_ request: ASAuthorizationAppleIDRequest) {
        
        let nonce =  RandomNonce.randomNonceString(length: 20)
                           currentNonce = nonce
                           request.requestedScopes = [.fullName, .email]
        request.nonce = RandomNonce.sha256(nonce)
        request.requestedScopes = [.fullName, .email]
    }
    
    private func handleAuthorization(_ authorization: ASAuthorization) {
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                UserDefaults.standard.set(credential.user, forKey: "userId")
                UserDefaults.standard.set(credential.email, forKey: "email")
                UserDefaults.standard.set(credential.fullName?.givenName, forKey: "firstName")
                UserDefaults.standard.set(credential.fullName?.familyName, forKey: "lastName")

                guard let idTokenData = credential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                let idTokenString = String(data: idTokenData, encoding: .utf8)
                
                // Authenticate with Firebase using the Apple ID credential
                signInWithAppleToFirebase(idToken: idTokenString, nonce: currentNonce)
            }
        }
        
        private func signInWithAppleToFirebase(idToken: String?, nonce: String?) {
            guard let idToken = idToken else { return }
            let credential = OAuthProvider.credential(providerID: AuthProviderID.apple, idToken: idToken, rawNonce: nonce ?? UUID().uuidString)
             
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print("Firebase sign in failed: \(error.localizedDescription)")
                    return
                }
                print("Successfully signed in with Firebase as user: \(authResult?.user.uid ?? "")")
                isLoggedIn = true
            }
        }
}

