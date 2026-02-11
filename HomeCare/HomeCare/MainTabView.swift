//
//  MainTabView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import SwiftUI

/// Vue principale avec TabBar
///
/// Contient la navigation par onglets entre :
/// - Le tableau de bord (activités)
/// - Les badges et récompenses
struct MainTabView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification partagé
    @Bindable var authService: AuthenticationService
    
    /// Onglet sélectionné
    @State private var selectedTab: Tab = .dashboard
    
    // MARK: - Tab Enum
    
    enum Tab {
        case dashboard
        case badges
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Onglet Dashboard
            DashboardView(authService: authService)
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(Tab.dashboard)
            
            // Onglet Badges
            BadgesView(authService: authService)
                .tabItem {
                    Label("Badges", systemImage: "medal.fill")
                }
                .tag(Tab.badges)
        }
        .tint(.blue) // Couleur de l'onglet actif
    }
}

// MARK: - Preview

#Preview {
    MainTabView(authService: AuthenticationService())
}
