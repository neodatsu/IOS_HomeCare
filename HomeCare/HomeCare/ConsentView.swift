//
//  ConsentView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue de demande de consentement RGPD
///
/// Affichée au premier lancement de l'application pour obtenir
/// le consentement explicite de l'utilisateur concernant le traitement
/// de ses données personnelles, conformément au RGPD.
struct ConsentView: View {
    
    // MARK: - Properties
    
    /// Callback appelé lorsque l'utilisateur accepte
    let onAccept: () -> Void
    
    /// Callback appelé lorsque l'utilisateur refuse
    let onDecline: () -> Void
    
    /// Indique si la politique de confidentialité est affichée
    @State private var showPrivacyPolicy = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 40)
                    
                    // Logo et titre
                    headerSection
                    
                    // Informations sur les données
                    dataInfoSection
                    
                    // Droits de l'utilisateur
                    rightsSection
                    
                    // Boutons d'action
                    actionButtons
                    
                    // Lien vers politique détaillée
                    policyLink
                    
                    Spacer()
                }
                .padding()
            }
            .background(backgroundGradient)
            .sheet(isPresented: $showPrivacyPolicy) {
                PrivacyPolicyView()
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
    
    /// Section d'en-tête
    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Confidentialité et données")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Votre vie privée est importante pour nous")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Section d'information sur les données
    private var dataInfoSection: some View {
        VStack(spacing: 20) {
            infoCard(
                icon: "person.text.rectangle.fill",
                title: "Données collectées",
                description: "Nous collectons votre nom, email et temps d'activités pour le fonctionnement de l'application."
            )
            
            infoCard(
                icon: "lock.shield.fill",
                title: "Sécurité",
                description: "Vos données sont protégées par chiffrement HTTPS et authentification OAuth2."
            )
            
            infoCard(
                icon: "arrow.left.arrow.right",
                title: "Pas de partage",
                description: "Vos données ne sont jamais vendues ou partagées avec des tiers."
            )
        }
    }
    
    /// Section des droits de l'utilisateur
    private var rightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Vos droits RGPD")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                rightRow(icon: "eye.fill", text: "Accéder à vos données")
                rightRow(icon: "pencil", text: "Rectifier vos données")
                rightRow(icon: "trash.fill", text: "Supprimer vos données")
                rightRow(icon: "arrow.down.doc.fill", text: "Exporter vos données")
                rightRow(icon: "hand.raised.fill", text: "Vous opposer au traitement")
            }
            
            Text("Contactez-nous à contact@itercraft.com pour exercer vos droits.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    /// Boutons d'action
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Bouton Accepter
            Button {
                onAccept()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    
                    Text("J'accepte")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
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
            .accessibilityLabel("J'accepte le traitement de mes données")
            .accessibilityHint("Appuyez pour accepter et continuer vers l'application")
            
            // Bouton Refuser
            Button {
                onDecline()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                    
                    Text("Je refuse")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.red.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
            .accessibilityLabel("Je refuse le traitement de mes données")
            .accessibilityHint("Appuyez pour refuser et quitter l'application")
        }
    }
    
    /// Lien vers la politique complète
    private var policyLink: some View {
        Button {
            showPrivacyPolicy = true
        } label: {
            Text("Lire la politique de confidentialité complète")
                .font(.footnote)
                .foregroundColor(.blue)
                .underline()
        }
        .accessibilityLabel("Lire la politique de confidentialité complète")
        .accessibilityAddTraits(.isLink)
    }
    
    // MARK: - Helper Views
    
    /// Carte d'information
    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
    
    /// Ligne de droit
    private func rightRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview("Consent") {
    ConsentView(
        onAccept: {
            print("Accepté")
        },
        onDecline: {
            print("Refusé")
        }
    )
}
