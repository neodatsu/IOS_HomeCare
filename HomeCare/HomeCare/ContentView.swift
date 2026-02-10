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
/// - L'écran de consentement RGPD (premier lancement)
/// - La page d'accueil (non authentifié)
/// - Le tableau de bord (authentifié)
///
/// La navigation est basée sur l'état d'authentification et du consentement.
struct ContentView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification partagé
    @State private var authService = AuthenticationService()
    
    /// Gestionnaire de consentement RGPD
    @State private var consentManager = ConsentManager()
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if !consentManager.hasGivenConsent {
                // Pas de consentement → Écran de consentement RGPD
                ConsentView(
                    onAccept: {
                        consentManager.giveConsent()
                    },
                    onDecline: {
                        // L'utilisateur refuse → Quitter l'app
                        exit(0)
                    }
                )
            } else if authService.isAuthenticated {
                // Consentement donné + Authentifié → Dashboard
                DashboardView(authService: authService)
            } else {
                // Consentement donné + Non authentifié → Page d'accueil
                HomeView(authService: authService)
            }
        }
        .animation(.easeInOut, value: consentManager.hasGivenConsent)
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
