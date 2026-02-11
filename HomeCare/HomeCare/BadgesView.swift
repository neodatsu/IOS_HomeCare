//
//  BadgesView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import SwiftUI

/// Vue des badges et récompenses
///
/// Affiche les badges obtenus par l'utilisateur en fonction de ses activités
/// et de son engagement dans l'application.
struct BadgesView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification pour accéder aux infos utilisateur
    @Bindable var authService: AuthenticationService
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // En-tête
                    headerSection
                    
                    // Badges à venir
                    comingSoonSection
                }
                .padding()
            }
            .background(backgroundGradient)
            .navigationTitle("Mes badges")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Components
    
    /// Dégradé de fond
    private var backgroundGradient: some View {
        ZStack {
            // Couche de base
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.15),
                    Color.yellow.opacity(0.08)
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
    
    /// Section d'en-tête
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Icône de badge
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "medal.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .symbolEffect(.pulse)
            
            Text("Vos récompenses")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Gagnez des badges en accomplissant vos activités")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    /// Section "Bientôt disponible"
    private var comingSoonSection: some View {
        VStack(spacing: 24) {
            // Grille de badges à venir
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                badgePreview(icon: "star.fill", title: "Débutant", color: .blue)
                badgePreview(icon: "flame.fill", title: "Assidu", color: .orange)
                badgePreview(icon: "bolt.fill", title: "Éclair", color: .yellow)
                badgePreview(icon: "crown.fill", title: "Expert", color: .purple)
                badgePreview(icon: "trophy.fill", title: "Champion", color: .green)
                badgePreview(icon: "heart.fill", title: "Passionné", color: .red)
            }
            
            // Message d'information
            VStack(spacing: 12) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("Bientôt disponible")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Le système de badges sera disponible dans une prochaine mise à jour. Continuez vos activités pour être prêt !")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
    }
    
    /// Badge preview
    private func badgePreview(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color.opacity(0.4))
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    BadgesView(authService: AuthenticationService())
}
