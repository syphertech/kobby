//
//  ActivityViewController.swift
//  kobby
//
//  Created by Maxwell Anane on 9/4/24.
//


import SwiftUI
import UIKit
//
struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any] = []
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed here
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
