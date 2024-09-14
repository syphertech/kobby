////
////  RecentNamesView.swift
////  kobby
////
////  Created by Maxwell Anane on 8/31/24.
////
//
//
//import SwiftUI
//
//struct RecentNamesView: View {
//    // Sample data for names
//    @State private var names: [NameEntry] = [
//        NameEntry(id: 1, name: "John Doe", timestamp: "Yesterday"),
//        NameEntry(id: 2, name: "Jane Smith", timestamp: "Today, 10:00 AM"),
//        NameEntry(id: 3, name: "Emily Brown", timestamp: "Today, 11:30 AM")
//    ]
//    
//    var body: some View {
//        List {
//            ForEach(names) { entry in
//                VStack(alignment: .leading) {
//                    Text(entry.name)
//                        .font(.headline)
//                    Text(entry.timestamp)
//                        .font(.footnote)
//                        .foregroundColor(.gray)
//                }
//                .padding(.vertical, 4)
//            }
//            .onDelete(perform: delete)
//        }
//        .navigationTitle("Recent Names")
//    }
//    
//    // Function to delete a name
//    private func delete(at offsets: IndexSet) {
//        names.remove(atOffsets: offsets)
//    }
//}
//
//struct NameEntry: Identifiable {
//    let id: Int
//    let name: String
//    let timestamp: String
//}
//
//struct RecentNamesView_Previews: PreviewProvider {
//    static var previews: some View {
//        RecentNamesView()
//    }
//}
