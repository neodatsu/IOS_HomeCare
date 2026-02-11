//
//  DashboardView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue du tableau de bord principal de l'application
///
/// Affiche le tableau de bord après authentification avec :
/// - Un en-tête avec menu burger et déconnexion
/// - Un message de bienvenue personnalisé avec le nom de l'utilisateur
/// - Les fonctionnalités principales de l'application
///
/// Cette vue respecte les normes RGAA avec des labels accessibles,
/// supporte Dynamic Type et le Dark Mode.
struct DashboardView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification pour accéder aux infos utilisateur et déconnexion
    @Bindable var authService: AuthenticationService
    
    /// Service de gestion des activités
    @State private var activityService: ActivityService
    
    /// Gestionnaire de consentement RGPD
    @State private var consentManager = ConsentManager()
    
    /// Indique si le menu est ouvert
    @State private var showMenu = false
    
    /// Indique si une erreur est survenue
    @State private var showError = false
    
    /// Message d'erreur à afficher
    @State private var errorMessage = ""
    
    /// Activité sélectionnée pour la navigation
    @State private var selectedActivity: Activity?
    
    // MARK: - Initialization
    
    /// Initialise le tableau de bord avec les services nécessaires
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
                    // Message de bienvenue
                    welcomeSection
                    
                    // Contenu du tableau de bord
                    dashboardContent
                    
                    // Récapitulatif des totaux
                    if activityService.totals != nil {
                        totalsSection
                    }
                }
                .padding()
            }
            .background(backgroundGradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    menuButton
                }
                
                ToolbarItem(placement: .principal) {
                    Text("HomeCare")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .sheet(isPresented: $showMenu) {
                menuSheet
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                // Charger les activités au chargement de la vue
                await loadActivities()
            }
            .refreshable {
                // Permettre le pull-to-refresh
                await loadActivities()
            }
            .navigationDestination(item: $selectedActivity) { activity in
                ActivityDetailView(
                    activity: activity,
                    activityService: activityService,
                    onDismiss: {
                        // Rafraîchir les données au retour
                        Task {
                            await loadActivities()
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Components
    
    /// Dégradé de fond adaptatif avec effets de lumière
    private var backgroundGradient: some View {
        ZStack {
            // Couche de base
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.08)
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
    
    /// Section de bienvenue avec le nom de l'utilisateur
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            // Icône de profil avec cercle propre
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)  // Couleur unie pour bon contraste
            }
            .accessibilityHidden(true)
            
            // Message de bienvenue
            VStack(spacing: 8) {
                Text("Bonjour")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(userName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Bonjour \(userName)")
            .accessibilityAddTraits(.isHeader)
        }
        .padding(.top, 20)
    }
    
    /// Contenu principal du tableau de bord
    private var dashboardContent: some View {
        VStack(spacing: 24) {
            // En-tête de la section activités
            HStack {
                Text("Mes activités")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if activityService.isLoading {
                    ProgressView()
                        .accessibilityLabel("Chargement en cours")
                }
            }
            
            // Liste des activités
            if activityService.activities.isEmpty && !activityService.isLoading {
                emptyStateView
            } else {
                activitiesList
            }
        }
    }
    
    /// Vue pour l'état vide (aucune activité)
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Aucune activité")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Vos activités de maintenance apparaîtront ici")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Aucune activité disponible")
    }
    
    /// Liste des activités
    private var activitiesList: some View {
        LazyVStack(spacing: 12) {
            ForEach(activityService.activities) { activity in
                ActivityCard(activity: activity)
                    .onTapGesture {
                        selectedActivity = activity
                    }
            }
        }
    }
    
    /// Section récapitulatif des totaux
    private var totalsSection: some View {
        VStack(spacing: 20) {
            // En-tête
            HStack {
                Text("Récapitulatif")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Totaux globaux
            if let totals = activityService.totals {
                VStack(spacing: 16) {
                    // Cartes de totaux par période
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
                    
                    // Détails par activité (si disponible)
                    if !totals.byActivity.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Par activité")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            
                            ForEach(totals.byActivity) { activityTotal in
                                ActivityTotalRow(activityTotal: activityTotal)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
    
    /// Bouton du menu burger
    private var menuButton: some View {
        Button {
            showMenu = true
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.title3)
                .foregroundColor(.primary)
        }
        .accessibilityLabel("Menu principal")
        .accessibilityHint("Appuyez pour ouvrir le menu")
        .accessibilityAddTraits(.isButton)
    }
    
    /// Feuille du menu avec options
    private var menuSheet: some View {
        NavigationStack {
            List {
                // Section Utilisateur
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.headline)
                            
                            if let email = authService.userInfo?.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Profil utilisateur. \(userName)")
                } header: {
                    Text("Profil")
                }
                
                // Section Actions
                Section {
                    Button(role: .destructive) {
                        Task {
                            showMenu = false
                            await authService.logout()
                        }
                    } label: {
                        Label("Se déconnecter", systemImage: "arrow.right.square")
                    }
                    .accessibilityLabel("Se déconnecter")
                    .accessibilityHint("Appuyez pour vous déconnecter de l'application")
                } header: {
                    Text("Actions")
                }
                
                // Section Légal
                Section {
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("Confidentialité", systemImage: "hand.raised.fill")
                    }
                    .accessibilityLabel("Politique de confidentialité")
                    
                    NavigationLink {
                        LegalView()
                    } label: {
                        Label("Mentions légales", systemImage: "doc.text.fill")
                    }
                    .accessibilityLabel("Mentions légales")
                    
                    Button(role: .destructive) {
                        Task {
                            showMenu = false
                            // Déconnecter l'utilisateur
                            await authService.logout()
                            // Puis révoquer le consentement
                            consentManager.revokeConsent()
                        }
                    } label: {
                        Label("Révoquer mon consentement", systemImage: "hand.raised.slash.fill")
                    }
                    .accessibilityLabel("Révoquer le consentement RGPD")
                    .accessibilityHint("Retire votre consentement et affiche à nouveau l'écran de consentement")
                } header: {
                    Text("Informations")
                }
            }
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        showMenu = false
                    }
                    .accessibilityLabel("Fermer le menu")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Computed Properties
    
    /// Nom de l'utilisateur à afficher
    private var userName: String {
        // Priorité : name > preferredUsername > email > "Utilisateur"
        if let name = authService.userInfo?.name, !name.isEmpty {
            return name
        } else if let username = authService.userInfo?.preferredUsername, !username.isEmpty {
            return username
        } else if let email = authService.userInfo?.email, !email.isEmpty {
            return email
        } else {
            return "Utilisateur"
        }
    }
    
    // MARK: - Methods
    
    /// Charge les activités depuis l'API
    private func loadActivities() async {
        do {
            try await activityService.loadAll()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Activity Card Component

/// Carte d'affichage d'une activité avec design propre
///
/// Composant réutilisable pour afficher une activité de maintenance
/// avec son icône, son libellé et son temps passé.
private struct ActivityCard: View {
    
    // MARK: - Properties
    
    let activity: Activity
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône dans cercle avec bon contraste
            ZStack {
                Circle()
                    .fill(activity.isActive ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 28))
                    .foregroundColor(activity.isActive ? .green : .blue)  // Couleur unie
            }
            .accessibilityHidden(true)
            
            // Informations
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.serviceLabel)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    if activity.isActive {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            
                            Text("En cours")
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if activity.totalMinutesToday > 0 {
                        Text(activity.formattedTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Pas encore démarrée")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(activity.serviceLabel). \(activity.isActive ? "En cours. " : "")\(activity.totalMinutesToday > 0 ? "Temps aujourd'hui: \(activity.formattedTime)" : "Pas encore démarrée")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Total Card Component

/// Carte affichant un total pour une période donnée
///
/// Composant réutilisable pour afficher les totaux par période
/// (aujourd'hui, semaine, mois, année)
private struct TotalCard: View {
    
    // MARK: - Properties
    
    let title: String
    let time: String
    let icon: String
    let color: Color
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(time)
                .font(.title3)
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
        .accessibilityLabel("\(title): \(time)")
    }
}

// MARK: - Activity Total Row Component

/// Ligne affichant le total d'une activité spécifique
///
/// Composant pour afficher les détails d'une activité dans le récapitulatif
private struct ActivityTotalRow: View {
    
    // MARK: - Properties
    
    let activityTotal: ActivityTotal
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 12) {
            // En-tête avec icône et nom
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: activityTotal.icon)
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                
                Text(activityTotal.serviceLabel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Grille de temps
            HStack(spacing: 8) {
                TimeBox(label: "J", time: activityTotal.formattedToday)
                TimeBox(label: "S", time: activityTotal.formattedWeek)
                TimeBox(label: "M", time: activityTotal.formattedMonth)
                TimeBox(label: "A", time: activityTotal.formattedYear)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
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
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(time)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(.systemBackground))
        )
    }
}

// MARK: - Preview

#Preview("Dashboard") {
    DashboardView(authService: {
        let service = AuthenticationService()
        // Simuler un utilisateur connecté pour la preview
        return service
    }())
}
