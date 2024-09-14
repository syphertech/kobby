import SwiftUI
import CoreData

struct AllPeopleView: View {
    @FetchRequest(
        entity: People.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \People.timestamp, ascending: false)]
    ) var names: FetchedResults<People>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText: String = ""
    @State private var isDeleting: Bool = false

    var body: some View {
        VStack {
            TextField("Search by name", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            if isDeleting {
                ProgressView("Deleting...").padding()
            } else if filteredNames.isEmpty {
                Text("No people found")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(filteredNames) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.name ?? "Unknown")
                                .font(.headline)
                            Text(DateFormatterHelper.formattedDate(from: entry.timestamp)) // Using the static function
                                                            .font(.subheadline)
                                                            .foregroundColor(.gray)
                            Text(entry.location ?? "Unknown Location")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(entry.notes ?? "No notes available")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: deletePeople)
                }
            }
        }
        .navigationTitle("All People")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
    }

    private var filteredNames: [People] {
        if searchText.isEmpty {
            return names.map { $0 }
        } else {
            return names.filter { person in
                person.name?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
    }

    private func deletePeople(at offsets: IndexSet) {
        isDeleting = true
        DispatchQueue.global(qos: .userInitiated).async {
            for index in offsets {
                let personToDelete = filteredNames[index]
                viewContext.delete(personToDelete)
                do {
                    try viewContext.save()
                } catch {
                    print("Error deleting person: \(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                isDeleting = false
            }
        }
    }
}
