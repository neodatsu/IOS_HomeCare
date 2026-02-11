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
/// - Les récapitulatifs (totaux par période)
/// - Le calendrier mensuel
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
        case totals
        case calendar
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
            
            // Onglet Récapitulatifs
            TotalsView(authService: authService)
                .tabItem {
                    Label("Récaps", systemImage: "chart.bar.fill")
                }
                .tag(Tab.totals)
            
            // Onglet Calendrier
            CalendarView(authService: authService)
                .tabItem {
                    Label("Calendrier", systemImage: "calendar")
                }
                .tag(Tab.calendar)
            
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
