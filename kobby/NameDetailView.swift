import SwiftUI
import CoreData

struct NameDetailView: View {
    @ObservedObject var entry: People
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss // To dismiss the view
    
    // State properties to hold editable text
    @State private var name: String = ""
    @State private var timestamp: String = ""
    @State private var location: String = ""
    @State private var notes: String = ""
    
    // State property to hold DatePicker's date value
    @State private var selectedDate: Date = Date()
    
    // Focus state properties
    @FocusState private var focusedField: Field?

    // Loading state for showing spinner
    @State private var loading: Bool = false
    
    enum Field {
        case name, location, notes
    }
    
    // DateFormatter for converting between Date and String
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        ZStack {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .name ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .name)
                }

                Section(header: Text("Timestamp")) {
                    DatePicker("Select Date", selection: $selectedDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])

                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding(8)
                        .onChange(of: selectedDate) { newValue in
                            timestamp = dateFormatter.string(from: newValue) // Update the timestamp string whenever the date is changed
                        }
                }
                
                Section(header: Text("Location")) {
                    TextField("Location", text: $location)
                        .font(.subheadline)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .location ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .location)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .font(.body)
                        .frame(height: 100)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .notes ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .focused($focusedField, equals: .notes)
                }
                
                Section {
                    Button(action: saveChanges) {
                        Text("Save")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.teal)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical)
                    
                }
                Section {
                    Button(action: deleteItem) {
                        Text("Delete")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize state properties with current entry values
                name = entry.name ?? "Unknown"
                timestamp = entry.timestamp ?? dateFormatter.string(from: Date())
                location = entry.location ?? "Unknown"
                notes = entry.notes ?? "No notes"
                
                // Convert timestamp string to Date
                if let entryDate = dateFormatter.date(from: timestamp) {
                    selectedDate = entryDate
                }
            }
            
            // Show spinner when loading is true
            if loading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()  // Dark overlay
                    ProgressView("Processing...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)  // Scale up the spinner
                }
            }
        }
    }

    private func saveChanges() {
        loading = true  // Show spinner when saving
        
        // Update Core Data entity with new values
        entry.name = name
        entry.timestamp = timestamp // Save the timestamp as a string
        entry.location = location
        entry.notes = notes
        
        // Use DispatchQueue.main.async to ensure UI updates and CoreData saves happen on the main thread
        DispatchQueue.main.async {
            do {
                try viewContext.save()
                loading = false  // Hide spinner after saving
                dismiss()  // Go back to the previous screen
            } catch {
                loading = false  // Hide spinner if there's an error
                print("Error saving changes: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteItem() {
        loading = true  // Show spinner when deleting
        
        // Ensure the deletion and context saving happens on the main thread
        DispatchQueue.main.async {
            viewContext.delete(entry)
            
            do {
                try viewContext.save()
                loading = false  // Hide spinner after deletion
                dismiss()  // Go back to the previous screen
            } catch {
                loading = false  // Hide spinner if there's an error
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }
}
