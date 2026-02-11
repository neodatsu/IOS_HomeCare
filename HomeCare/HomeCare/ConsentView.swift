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
    
    /// Dégradé de fond avec effets de lumière améliorés
    private var backgroundGradient: some View {
        ZStack {
            // Couche de base avec des couleurs plus douces
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),  // Bleu très pâle
                    Color(red: 0.98, green: 0.96, blue: 1.0)   // Violet très pâle
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Couche de lumière subtile
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.6),
                    Color.clear
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
    
    /// Section d'en-tête avec icône lisible
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Icône avec cercle lisible
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)  // Couleur unie pour meilleur contraste
            }
            
            // Textes dans conteneur subtil
            VStack(spacing: 10) {
                Text("Confidentialité et données")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text("Votre vie privée est importante pour nous")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
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
    
    /// Section des droits de l'utilisateur avec design propre
    private var rightsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Vos droits RGPD")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 14) {
                rightRow(icon: "eye.fill", text: "Accéder à vos données")
                rightRow(icon: "pencil", text: "Rectifier vos données")
                rightRow(icon: "trash.fill", text: "Supprimer vos données")
                rightRow(icon: "arrow.down.doc.fill", text: "Exporter vos données")
                rightRow(icon: "hand.raised.fill", text: "Vous opposer au traitement")
            }
            
            Text("Contactez-nous à **contact@itercraft.com** pour exercer vos droits.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    /// Boutons d'action avec design propre
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Bouton Accepter - Style simple et élégant
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
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.green)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("J'accepte le traitement de mes données")
            .accessibilityHint("Appuyez pour accepter et continuer vers l'application")
            
            // Bouton Refuser - Style secondaire
            Button {
                onDecline()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                    
                    Text("Je refuse")
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red, lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
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
    
    /// Carte d'information avec icônes lisibles
    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icône dans un cercle avec bon contraste
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)  // Couleur unie pour meilleur contraste
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
    
    /// Ligne de droit avec icônes lisibles
    private func rightRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)  // Couleur unie pour meilleur contraste
            }
            
            Text(text)
                .font(.callout)
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
