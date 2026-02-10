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
    
    /// Temps écoulé en secondes
    @State private var elapsedSeconds: Int = 0
    
    /// Timer pour mettre à jour le chronomètre
    @State private var timer: Timer?
    
    /// Indique si le chronomètre est en pause
    @State private var isPaused: Bool = false
    
    /// Activité mise à jour avec le dernier état du serveur
    @State private var currentActivity: Activity
    
    /// Indique si une opération est en cours
    @State private var isLoading = false
    
    /// Indique si une erreur est survenue
    @State private var showError = false
    
    /// Message d'erreur à afficher
    @State private var errorMessage = ""
    
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
            }
            .onDisappear {
                stopTimer()
                // Rafraîchir au retour
                onDismiss()
            }
        }
    }
    
    // MARK: - Components
    
    /// Dégradé de fond
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.05),
                Color.purple.opacity(0.02)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    /// Icône de l'activité
    private var activityIcon: some View {
        Image(systemName: activity.icon)
            .font(.system(size: 80))
            .foregroundStyle(
                LinearGradient(
                    colors: activity.isActive ? [.green, .blue] : [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 120)
            .background(
                Circle()
                    .fill(activity.isActive ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
            )
            .accessibilityHidden(true)
    }
    
    /// Titre de l'activité
    private var activityTitle: some View {
        Text(activity.serviceLabel)
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }
    
    /// Chronomètre numérique
    private var chronometer: some View {
        VStack(spacing: 12) {
            Text(formattedTime)
                .font(.system(size: 72, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            if currentActivity.isActive {
                HStack(spacing: 4) {
                    Circle()
                        .fill(isPaused ? Color.orange : Color.green)
                        .frame(width: 12, height: 12)
                    
                    Text(isPaused ? "En pause" : "En cours")
                        .font(.headline)
                        .foregroundColor(isPaused ? .orange : .green)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Chronomètre. \(formattedTime). \(currentActivity.isActive ? (isPaused ? "En pause" : "Activité en cours") : "Activité arrêtée")")
    }
    
    /// Boutons de contrôle Start/Pause/Stop
    private var controlButtons: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                // Bouton Start
                Button {
                    startActivity()
                } label: {
                    HStack(spacing: 12) {
                        if isLoading && !currentActivity.isActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.title2)
                        }
                        
                        Text("Start")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(currentActivity.isActive || isLoading)
                .opacity(currentActivity.isActive ? 0.5 : 1.0)
                .accessibilityLabel("Démarrer l'activité")
                .accessibilityHint(currentActivity.isActive ? "Activité déjà en cours" : "Appuyez pour démarrer le chronomètre")
                .accessibilityAddTraits(.isButton)
                
                // Bouton Stop
                Button {
                    stopActivity()
                } label: {
                    HStack(spacing: 12) {
                        if isLoading && currentActivity.isActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "stop.fill")
                                .font(.title2)
                        }
                        
                        Text("Stop")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(!currentActivity.isActive || isLoading)
                .opacity(!currentActivity.isActive ? 0.5 : 1.0)
                .accessibilityLabel("Arrêter l'activité")
                .accessibilityHint(!currentActivity.isActive ? "Aucune activité en cours" : "Appuyez pour arrêter le chronomètre")
                .accessibilityAddTraits(.isButton)
            }
            
            // Bouton Pause (seulement si activité en cours)
            if currentActivity.isActive {
                Button {
                    togglePause()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                            .font(.title2)
                        
                        Text(isPaused ? "Reprendre" : "Pause")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: isPaused ? [.green, .blue] : [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: (isPaused ? Color.green : Color.orange).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading)
                .accessibilityLabel(isPaused ? "Reprendre le chronomètre" : "Mettre en pause le chronomètre")
                .accessibilityHint("Pause locale, ne synchronise pas avec le serveur")
                .accessibilityAddTraits(.isButton)
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
    
    /// Temps formaté en HH:MM:SS
    private var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - Methods
    
    /// Configure l'état initial basé sur l'activité
    private func setupInitialState() {
        // Toujours commencer à 0 pour un nouveau démarrage
        elapsedSeconds = 0
        
        if currentActivity.isActive {
            // Si l'activité est déjà en cours, calculer le temps écoulé depuis startedAt
            if let startedAt = currentActivity.startedAt {
                elapsedSeconds = Int(Date().timeIntervalSince(startedAt))
            }
            startTimer()
        }
        // Sinon, rester à 0 et attendre que l'utilisateur clique sur Start
    }
    
    /// Démarre le chronomètre
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                elapsedSeconds += 1
            }
        }
    }
    
    /// Arrête le chronomètre
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Met en pause ou reprend le chronomètre (local seulement)
    private func togglePause() {
        isPaused.toggle()
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
                    
                    // Démarrer le timer
                    elapsedSeconds = 0
                    if let startedAt = currentActivity.startedAt {
                        elapsedSeconds = Int(Date().timeIntervalSince(startedAt))
                    }
                    isPaused = false
                    startTimer()
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
                
                // Arrêter le timer et remettre à zéro
                stopTimer()
                isPaused = false
                elapsedSeconds = 0  // ✅ Remettre le compteur à 0
                
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

// MARK: - Stat Card Component

/// Carte de statistique
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
                .stroke(color.opacity(0.3), lineWidth: 1)
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
