//
//  ActivityDetailView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue de détail d'une activité avec chronomètre
///
/// Affiche un chronomètre numérique pour une activité spécifique avec :
/// - Affichage du temps écoulé en format HH:MM:SS
/// - Bouton Start pour démarrer l'activité
/// - Bouton Stop pour arrêter l'activité
/// - Statistiques du temps passé aujourd'hui
///
/// Les actions déclenchent des appels API vers le backend pour
/// enregistrer les temps d'exécution.
///
/// Cette vue respecte les normes RGAA et supporte le Dark Mode.
struct ActivityDetailView: View {
    
    // MARK: - Properties
    
    /// Activité à chronomètrer
    let activity: Activity
    
    /// Service d'activités pour les appels API
    @Bindable var activityService: ActivityService
    
    /// Callback appelé lors du retour au dashboard
    let onDismiss: () -> Void
    
    /// Activité mise à jour avec le dernier état du serveur
    @State private var currentActivity: Activity
    
    /// Indique si une opération est en cours
    @State private var isLoading = false
    
    /// Indique si une erreur est survenue
    @State private var showError = false
    
    /// Message d'erreur à afficher
    @State private var errorMessage = ""
    
    /// Timer pour rafraîchir l'affichage toutes les secondes
    @State private var displayTimer: Timer?
    
    /// Gestionnaire de timer partagé
    private var timerManager: TimerManager {
        TimerManager.shared
    }
    
    // MARK: - Initialization
    
    /// Initialise la vue avec l'activité
    init(activity: Activity, activityService: ActivityService, onDismiss: @escaping () -> Void) {
        self.activity = activity
        self.activityService = activityService
        self.onDismiss = onDismiss
        self._currentActivity = State(initialValue: activity)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Icône de l'activité
                    activityIcon
                    
                    // Nom de l'activité
                    activityTitle
                    
                    // Chronomètre
                    chronometer
                    
                    // Boutons de contrôle
                    controlButtons
                    
                    // Statistiques
                    statistics
                    
                    Spacer()
                }
                .padding()
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                setupInitialState()
                startDisplayTimer()
            }
            .onDisappear {
                stopDisplayTimer()
                // Rafraîchir au retour
                onDismiss()
            }
        }
    }
    
    // MARK: - Components
    
    /// Fond minimaliste moderne 2026
    private var backgroundGradient: some View {
        Color(.systemBackground)
            .ignoresSafeArea()
    }
    
    /// Icône de l'activité - Design moderne épuré
    private var activityIcon: some View {
        ZStack {
            Circle()
                .fill(activity.isActive ? Color.green.opacity(0.12) : Color.blue.opacity(0.12))
                .frame(width: 100, height: 100)
            
            Image(systemName: activity.icon)
                .font(.system(size: 50))
                .foregroundColor(activity.isActive ? .green : .blue)
        }
        .accessibilityHidden(true)
    }
    
    /// Titre de l'activité - Minimaliste
    private var activityTitle: some View {
        Text(activity.serviceLabel)
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Chronomètre numérique - Design moderne minimaliste
    private var chronometer: some View {
        TimelineView(.periodic(from: Date(), by: 1.0)) { _ in
            let formatted = TimerManager.shared.formattedTime
            
            VStack(spacing: 16) {
                Text(formatted)
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                if currentActivity.isActive {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(TimerManager.shared.isPaused ? Color.orange : Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text(TimerManager.shared.isPaused ? "En pause" : "En cours")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(TimerManager.shared.isPaused ? .orange : .green)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemBackground))
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Chronomètre. \(formatted)")
        }
    }
    
    /// Boutons de contrôle - Design 2026 minimaliste
    private var controlButtons: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                // Bouton Start - Minimaliste vert
                Button {
                    startActivity()
                } label: {
                    VStack(spacing: 10) {
                        if isLoading && !currentActivity.isActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.green)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        
                        Text("Start")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(currentActivity.isActive ? 0.2 : 0.4), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(currentActivity.isActive || isLoading)
                .opacity(currentActivity.isActive ? 0.5 : 1.0)
                .accessibilityLabel("Démarrer l'activité")
                .accessibilityHint(currentActivity.isActive ? "Activité déjà en cours" : "Appuyez pour démarrer le chronomètre")
                
                // Bouton Stop - Minimaliste rouge
                Button {
                    stopActivity()
                } label: {
                    VStack(spacing: 10) {
                        if isLoading && currentActivity.isActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.red)
                        } else {
                            Image(systemName: "stop.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        
                        Text("Stop")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.red.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red.opacity(!currentActivity.isActive ? 0.2 : 0.4), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(!currentActivity.isActive || isLoading)
                .opacity(!currentActivity.isActive ? 0.5 : 1.0)
                .accessibilityLabel("Arrêter l'activité")
                .accessibilityHint(!currentActivity.isActive ? "Aucune activité en cours" : "Appuyez pour arrêter le chronomètre")
            }
            
            // Bouton Pause - Minimaliste orange (seulement si activité en cours)
            if currentActivity.isActive {
                Button {
                    togglePause()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: timerManager.isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.title2)
                        
                        Text(timerManager.isPaused ? "Reprendre" : "Pause")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(timerManager.isPaused ? .green : .orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill((timerManager.isPaused ? Color.green : Color.orange).opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke((timerManager.isPaused ? Color.green : Color.orange).opacity(0.3), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .accessibilityLabel(timerManager.isPaused ? "Reprendre le chronomètre" : "Mettre en pause le chronomètre")
                .accessibilityHint("Pause locale, ne synchronise pas avec le serveur")
            }
        }
    }
    
    /// Statistiques du jour
    private var statistics: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Aujourd'hui")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatCard(
                    icon: "clock.fill",
                    title: "Temps total",
                    value: currentActivity.formattedTime,  // ✅ Utilise currentActivity mis à jour
                    color: .blue
                )
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Computed Properties
    
    // (Supprimé - formattedTime maintenant dans timerManager)
    
    // MARK: - Methods
    
    /// Configure l'état initial basé sur l'activité
    private func setupInitialState() {
        // Si l'activité API est active mais que le timer manager ne l'est pas encore
        if currentActivity.isActive, TimerManager.shared.activeServiceCode != currentActivity.serviceCode {
            // Synchroniser avec le timer manager
            if let startedAt = currentActivity.startedAt {
                TimerManager.shared.startActivity(
                    serviceCode: currentActivity.serviceCode,
                    serviceLabel: currentActivity.serviceLabel,
                    icon: currentActivity.icon,
                    startDate: startedAt
                )
            }
        }
    }
    
    /// Démarre le timer d'affichage pour rafraîchir l'interface
    private func startDisplayTimer() {
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak timerManager] _ in
            // Force le rafraîchissement de l'UI en accédant à une propriété
            _ = timerManager?.elapsedSeconds
        }
    }
    
    /// Arrête le timer d'affichage
    private func stopDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = nil
    }
    
    /// Met en pause ou reprend le chronomètre (local seulement)
    private func togglePause() {
        if timerManager.isPaused {
            timerManager.resume()
        } else {
            timerManager.pause()
        }
    }
    
    /// Démarre l'activité via l'API
    private func startActivity() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await activityService.startActivity(serviceCode: currentActivity.serviceCode)
                
                // Recharger l'activité pour avoir le nouvel état
                try await activityService.loadActivities()
                
                // Trouver l'activité mise à jour
                if let updated = activityService.activities.first(where: { $0.serviceCode == currentActivity.serviceCode }) {
                    currentActivity = updated
                    
                    // Démarrer le timer manager
                    if let startedAt = currentActivity.startedAt {
                        timerManager.startActivity(
                            serviceCode: currentActivity.serviceCode,
                            serviceLabel: currentActivity.serviceLabel,
                            icon: currentActivity.icon,
                            startDate: startedAt
                        )
                    }
                }
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
    
    /// Arrête l'activité via l'API
    private func stopActivity() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await activityService.stopActivity(serviceCode: currentActivity.serviceCode)
                
                // Recharger l'activité pour avoir le nouvel état et les totaux mis à jour
                try await activityService.loadActivities()
                
                // Trouver l'activité mise à jour avec le temps total du jour
                if let updated = activityService.activities.first(where: { $0.serviceCode == currentActivity.serviceCode }) {
                    currentActivity = updated
                }
                
                // Arrêter le timer manager
                timerManager.stopActivity()
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Stat Card Component

/// Carte de statistique - Design 2026 minimaliste
private struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Preview

#Preview {
    ActivityDetailView(
        activity: Activity.samples[1], // Karcher en cours
        activityService: ActivityService(authService: AuthenticationService()),
        onDismiss: { }
    )
}
