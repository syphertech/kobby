//
//  RecentNamesView.swift
//  kobby
//
//  Created by Maxwell Anane on 8/31/24.
//

import SwiftUI

struct RecentNamesView: View {
    // Sample data for names
    @FetchRequest(
        entity: People.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \People.timestamp, ascending: false)]
        ) var names: FetchedResults<People>
        
        @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            List {
                // Recent Names Section
                Section(header: Text("Recent Names")) {
                    if names.isEmpty {
                        // Display message when no results are available
                        
                        ContentUnavailableView("No new friends", systemImage: "person.2", description: Text("You have'nt met any one new recently"))
                            .symbolVariant(.slash)
                    
                    } else {
                        ForEach(names) { entry in
                            NavigationLink(destination: NameDetailView(entry: entry)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(entry.name ?? String("uknown"))
                                            .font(.headline)
                                        Text(DateFormatterHelper.formattedDate(from: entry.timestamp)) // Using the static function
                                                                        .font(.subheadline)
                                                                        .foregroundColor(.gray)
                                        Text(entry.location ?? String("uknown"))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text(entry.notes ?? String("no notes added"))
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            
                            }
                        }
                        .onDelete(perform: delete)
            
                    }
                    
                }
               
             
            
            }
        }
    }
    
    // Function to delete a name
     func delete(at offsets: IndexSet) {
          for index in offsets {
              let name = names[index]
              viewContext.delete(name)
          }
          do {
              try viewContext.save()
          } catch {
              // Handle the Core Data error
              print("Error deleting item: \(error)")
          }
      }
}







struct RecentNamesView_Previews: PreviewProvider {
    static var previews: some View {
        RecentNamesView()
    }
}
