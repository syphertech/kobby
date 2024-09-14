import SwiftUI
import CoreLocation

struct AddPersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedDate: Date = Date()
    @State private var useCurrentDate: Bool = true
    @State private var location: String = ""
    @State private var notes: String = " "
    @State private var useCurrentLocation: Bool = true
    @State private var loading: Bool = false  // Add loading state
    
    // Use the shared instance of LocationManager
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    // Name Input
                    Section(header: Text("Name")) {
                        TextField("Enter name", text: $name)
                    }
                    
                    // Date Input
                    Section(header: Text("Date")) {
                        Toggle("Use current date", isOn: $useCurrentDate)
                        if !useCurrentDate {
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        }
                    }
                    
                    // Location Input
                    Section(header: Text("Location")) {
                        Toggle("Use current location", isOn: $useCurrentLocation)
                        if useCurrentLocation {
                            Text("Current location: \(currentLocationDescription)")
                                .onAppear {
                                    locationManager.checkLocationAuthorization()
                                }
                        } else {
                            TextField("Enter location", text: $location)
                        }
                    }
                    
                    Section(header:Text("Notes")){
                        TextField("Add any notes about this person", text: $notes)
                    }
                    
                    // Save Button
                    Section {
                        Button(action: savePerson) {
                            Text("Save")
                                .foregroundStyle(.teal)
                                .font(.headline).fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                .navigationTitle(Text("Add Name"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button("Dismiss") {
                        dismiss()
                    }.foregroundColor(.white)
                }
                .toolbarBackground(.teal, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .tint(.teal)
                
                // Show spinner when loading is true
                if loading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()  // Dark overlay
                        ProgressView("Saving...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)  // Scale up the spinner
                    }
                }
            }
        }
    }
    
    // Computed property to display location description
    private var currentLocationDescription: String {
        return locationManager.currentPlaceName
    }
    
    // Function to save a person to Core Data
    private func savePerson() {
        loading = true  // Start showing the spinner

        DispatchQueue.global().async {
            // Perform save operation on background thread
            let newEntry = People(context: viewContext)
            newEntry.id = UUID()
            newEntry.name = name
            newEntry.timestamp = useCurrentDate ? DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none) : DateFormatter.localizedString(from: selectedDate, dateStyle: .medium, timeStyle: .none)
            newEntry.location = useCurrentLocation ? currentLocationDescription : location
            newEntry.notes = notes
            
            do {
                try viewContext.save()
                
                DispatchQueue.main.async {
                    // Hide spinner and dismiss view after saving
                    loading = false
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    loading = false  // Hide spinner if there's an error
                }
                print("Error saving new person: \(error.localizedDescription)")
            }
        }
    }
}

struct AddPersonView_Previews: PreviewProvider {
    static var previews: some View {
        AddPersonView().environment(\.managedObjectContext, DataController.shared.container.viewContext)
    }
}
