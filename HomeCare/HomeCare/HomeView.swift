//
//  HomeView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue d'accueil principale de l'application HomeCare avec design Liquid Glass
///
/// Affiche l'écran d'accueil avec :
/// - Le logo de l'application (icône maison avec cœur)
/// - Le nom de l'application "HomeCare"
/// - Le sous-titre "by IterCraft"
/// - Un bouton d'action principal pour commencer avec effet Liquid Glass
/// - Un bouton de connexion via Keycloak
///
/// Cette vue respecte les normes RGAA avec des labels accessibles,
/// supporte Dynamic Type et le Dark Mode, et utilise le design Liquid Glass moderne.
struct HomeView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification Keycloak
    @Bindable var authService: AuthenticationService
    
    /// Indique si une erreur d'authentification est survenue
    @State private var showError = false
    
    /// Message d'erreur à afficher
    @State private var errorMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Fond avec dégradé dynamique
            backgroundGradient
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo et titre
                headerSection
                
                // Bouton de connexion
                loginButton
                
                Spacer()
                
                // Footer avec crédit
                footerSection
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Page d'accueil HomeCare")
        .alert("Erreur d'authentification", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Components
    
    /// Fond moderne 2026 - Minimaliste et lumineux
    private var backgroundGradient: some View {
        ZStack {
            // Fond ultra pâle
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.98, green: 0.99, blue: 1.0),
                    Color(red: 0.99, green: 0.98, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Lumière subtile
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.8),
                    Color.clear
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
    
    /// Section d'en-tête avec logo et titre
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Icône principale
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse)
                .accessibilityHidden(true) // Décoratif, la description est dans le titre
            
            // Titre principal
            Text("HomeCare")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .indigo],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel("HomeCare")
            
            // Sous-titre
            Text("by IterCraft")
                .font(.title3)
                .foregroundColor(.secondary)
                .accessibilityLabel("par IterCraft")
        }
    }
    
    /// Bouton de connexion avec style propre
    private var loginButton: some View {
        Button {
            Task {
                do {
                    try await authService.login()
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                
                Text("Me connecter")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [.blue, .indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Me connecter")
        .accessibilityHint("Appuyez pour vous authentifier via IterCraft")
        .accessibilityAddTraits(.isButton)
    }
    
    /// Section de pied de page
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Version 1.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Version 1.0")
            
            Text("© 2026 IterCraft")
                .font(.caption2)
                .foregroundColor(.secondary)
                .accessibilityLabel("Copyright 2026 IterCraft")
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    HomeView(authService: AuthenticationService())
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HomeView(authService: AuthenticationService())
        .preferredColorScheme(.dark)
}

#Preview("Dynamic Type - Large") {
    HomeView(authService: AuthenticationService())
        .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
}
