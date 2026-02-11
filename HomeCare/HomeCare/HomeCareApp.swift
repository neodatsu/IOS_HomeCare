//
//  HomeCareApp.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

@main
struct HomeCareApp: App {
    /// Gestionnaire de consentement partagé dans toute l'app
    @State private var consentManager = ConsentManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(consentManager)
        }
    }
}
