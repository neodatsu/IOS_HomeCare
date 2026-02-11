//
//  TotalsView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import SwiftUI

/// Vue des récapitulatifs d'activités
///
/// Affiche les totaux globaux et par activité pour différentes périodes
/// (jour, semaine, mois, année).
struct TotalsView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification pour accéder aux infos utilisateur
    @Bindable var authService: AuthenticationService
    
    /// Service de gestion des activités
    @State private var activityService: ActivityService
    
    /// Indique si une erreur est survenue
    @State private var showError = false
    
    /// Message d'erreur à afficher
    @State private var errorMessage = ""
    
    // MARK: - Initialization
    
    /// Initialise la vue des totaux avec les services nécessaires
    ///
    /// - Parameter authService: Service d'authentification
    init(authService: AuthenticationService) {
        self.authService = authService
        self._activityService = State(initialValue: ActivityService(authService: authService))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    if activityService.isLoading {
                        // État de chargement
                        loadingView
                    } else if let totals = activityService.totals {
                        // Totaux globaux
                        globalTotalsSection(totals)
                        
                        // Totaux par activité
                        if !totals.byActivity.isEmpty {
                            activityTotalsSection(totals.byActivity)
                        }
                    } else {
                        // Aucune donnée
                        emptyStateView
                    }
                }
                .padding()
            }
            .background(backgroundGradient)
            .navigationTitle("Récapitulatifs")
            .navigationBarTitleDisplayMode(.large)
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }
    
    // MARK: - Components
    
    /// Dégradé de fond
    private var backgroundGradient: some View {
        ZStack {
            // Couche de base
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.15),
                    Color.teal.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Couche de lumière
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
    
    /// Vue de chargement
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Chargement des données...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
    
    /// Vue d'état vide
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucune donnée")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Commencez une activité pour voir vos statistiques")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    /// Section des totaux globaux
    private func globalTotalsSection(_ totals: ActivityTotals) -> some View {
        VStack(spacing: 20) {
            // En-tête
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Totaux globaux")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Cartes de totaux par période
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    TotalCard(
                        title: "Aujourd'hui",
                        time: totals.formattedToday,
                        icon: "sun.max.fill",
                        color: .orange
                    )
                    
                    TotalCard(
                        title: "Semaine",
                        time: totals.formattedWeek,
                        icon: "calendar.badge.clock",
                        color: .blue
                    )
                }
                
                HStack(spacing: 12) {
                    TotalCard(
                        title: "Mois",
                        time: totals.formattedMonth,
                        icon: "calendar",
                        color: .purple
                    )
                    
                    TotalCard(
                        title: "Année",
                        time: totals.formattedYear,
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                }
            }
        }
    }
    
    /// Section des totaux par activité
    private func activityTotalsSection(_ activityTotals: [ActivityTotal]) -> some View {
        VStack(spacing: 20) {
            // En-tête
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Par activité")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Liste des activités
            VStack(spacing: 12) {
                ForEach(activityTotals) { activityTotal in
                    ActivityTotalRow(activityTotal: activityTotal)
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Charge les données
    private func loadData() async {
        do {
            try await activityService.loadAll()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Total Card Component

/// Carte affichant un total pour une période donnée
private struct TotalCard: View {
    
    // MARK: - Properties
    
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .symbolEffect(.bounce, options: .speed(0.5))
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(time)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(time)")
    }
}

// MARK: - Activity Total Row Component

/// Ligne affichant le total d'une activité spécifique
private struct ActivityTotalRow: View {
    
    // MARK: - Properties
    
    let activityTotal: ActivityTotal
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // En-tête avec icône et nom
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: activityTotal.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                Text(activityTotal.serviceLabel)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Grille de temps
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                TimeBox(label: "Aujourd'hui", time: activityTotal.formattedToday, color: .orange)
                TimeBox(label: "Semaine", time: activityTotal.formattedWeek, color: .blue)
                TimeBox(label: "Mois", time: activityTotal.formattedMonth, color: .purple)
                TimeBox(label: "Année", time: activityTotal.formattedYear, color: .green)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activityTotal.serviceLabel). Aujourd'hui: \(activityTotal.formattedToday). Semaine: \(activityTotal.formattedWeek). Mois: \(activityTotal.formattedMonth). Année: \(activityTotal.formattedYear)")
    }
}

// MARK: - Time Box Component

/// Petite boîte affichant un temps pour une période
private struct TimeBox: View {
    
    let label: String
    let time: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
                .textCase(.uppercase)
            
            Text(time)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    TotalsView(authService: AuthenticationService())
}
