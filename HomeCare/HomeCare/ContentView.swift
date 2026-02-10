//
//  ContentView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue principale de l'application HomeCare
///
/// Cette vue gère la navigation entre :
/// - La page d'accueil (non authentifié)
/// - Le tableau de bord (authentifié)
///
/// La navigation est basée sur l'état d'authentification du service.
struct ContentView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification partagé
    @State private var authService = AuthenticationService()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                // Utilisateur connecté → Tableau de bord
                DashboardView(authService: authService)
            } else {
                // Utilisateur non connecté → Page d'accueil
                HomeView(authService: authService)
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
