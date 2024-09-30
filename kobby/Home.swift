import SwiftUI
import Security
import WatchConnectivity
import CoreData

struct HomeView: View {
    @FetchRequest(
        entity: People.entity(),
        sortDescriptors: [NSSortDescriptor(
            keyPath: \People.timestamp,
            ascending: false
        )]
    ) var names: FetchedResults<People>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @State private var isSheetPresented = false
    @State private var isSheetWithNavPresented = false
    @State private var isFullScreenCoverPresented = false
    @State private var buttonScale: CGFloat = 0.8 // Initial scale for animation
    @State private var isWatchConnected: Bool = false
    
    // Initialize AudioReceiver with Core Data context
    @StateObject private var audioReceiver: AudioReceiver
    
    // Custom init to pass NSManagedObjectContext to AudioReceiver
    init() {
        _audioReceiver = StateObject(wrappedValue: AudioReceiver(context: DataController.shared.container.viewContext))
    }
    
    private var iconColor: Color {
        colorScheme == .dark ? .teal : .indigo
    }
    
    private var iconLingColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    private var iconShadow: CGFloat {
        colorScheme == .dark ? 0.4 : 0.2
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                
                Section {
                    RecentNamesView()
                }
                .scrollIndicators(.hidden)
                
                HStack(spacing: 20) {
                    // Add Name Manually Button
                    Button {
                        isFullScreenCoverPresented = true
                    } label: {
                        VStack {
                            Image(systemName: "person.badge.plus")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(iconColor)
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 10)
                            Text("Add name manually")
                                .fontWeight(.bold)
                                .foregroundStyle(iconColor)
                                .padding()
                        }
                        .frame(width: 160, height: 160)
                        .padding(.leading,10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.systemBackground))
                        )
                        .shadow(
                            color: .gray.opacity(iconShadow),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                        .scaleEffect(buttonScale)
                    }
                    .fullScreenCover(isPresented: $isFullScreenCoverPresented) {
                        AddPersonView()
                    }
                    
                    // View All People Button
                    NavigationLink(destination: AllPeopleView()) {
                        VStack {
                            Image(systemName: "person.3.fill")
                                .resizable()
                                .scaledToFill()
                                .foregroundStyle(iconLingColor)
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 10)
                            Text("View all people")
                                .fontWeight(.bold)
                                .foregroundStyle(iconLingColor)
                                .padding()
                        }
                        .frame(width: 200, height: 160)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(iconColor))
                        )
                        .shadow(
                            color: .gray.opacity(iconShadow),
                            radius: 5,
                            x: 0,
                            y: 2
                        ).padding(.trailing,10)
                        .scaleEffect(buttonScale)
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.5)) {
                    buttonScale = 1.0 // Animate scale effect to normal size
                }
                setupWatchConnectivity()
            }
            .padding(.horizontal,10)
    
           
            .navigationTitle("Home") // Add navigation title for HomeView
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: RecievedFiles()) {
                        Image(systemName: "mic")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: connectToWatch) {
                        Image(systemName: isWatchConnected ? "applewatch.radiowaves.left.and.right" : "applewatch.slash")
                            .foregroundColor(isWatchConnected ? .green : .red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: logout) {
                        Image(systemName: "escape")
                            .foregroundColor(.red)
                    }
                }
            }
        }
    }

    // Function to connect to Apple Watch
    private func connectToWatch() {
        if WCSession.default.isPaired && WCSession.default.isWatchAppInstalled {
            if WCSession.default.isReachable {
                // Successfully connected to Watch
                isWatchConnected = true
            } else {
                // Try to send a message to the Watch
                WCSession.default.sendMessage(["request": "connect"], replyHandler: nil, errorHandler: nil)
            }
        } else {
            isWatchConnected = false
        }
    }
    
    // Set up the WatchConnectivity session with the AudioReceiver
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            // AudioReceiver instance is already initialized and set as the delegate
            WCSession.default.delegate = audioReceiver
            WCSession.default.activate()
        }
    }

    // Function to log the user out
    private func logout() {
        clearUserData()
    }
    
    // Function to clear user data or credentials
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name("UserLoggedOut"), object: nil)
    }
}

#Preview {
    HomeView()
}
