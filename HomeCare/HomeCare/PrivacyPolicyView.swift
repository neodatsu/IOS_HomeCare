//
//  PrivacyPolicyView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue de la politique de confidentialité
///
/// Affiche la politique de confidentialité conforme au RGPD
/// avec les informations sur la collecte et le traitement des données.
struct PrivacyPolicyView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Group {
                        section(
                            title: "1. Responsable du traitement",
                            content: """
                            IterCraft
                            Responsable: Laurent FERRER
                            
                            Pour toute question concernant vos données personnelles, contactez-nous à : contact@itercraft.com
                            """
                        )
                        
                        section(
                            title: "2. Données collectées",
                            content: """
                            Nous collectons les données suivantes :
                            • Nom et prénom
                            • Adresse email
                            • Identifiant utilisateur
                            • Temps passés sur les activités de maintenance
                            
                            Ces données sont collectées lors de votre authentification via le serveur Keycloak (authent.itercraft.com).
                            """
                        )
                        
                        section(
                            title: "3. Finalité du traitement",
                            content: """
                            Vos données sont utilisées uniquement pour :
                            • Vous authentifier sur l'application
                            • Enregistrer vos temps d'activités
                            • Générer des statistiques personnelles
                            • Améliorer les fonctionnalités de l'application
                            
                            Aucune donnée n'est utilisée à des fins publicitaires ou commerciales.
                            """
                        )
                        
                        section(
                            title: "4. Base légale",
                            content: """
                            Le traitement de vos données est basé sur :
                            • Votre consentement explicite
                            • L'exécution du service demandé
                            """
                        )
                    }
                    
                    Group {
                        section(
                            title: "5. Durée de conservation",
                            content: """
                            Vos données sont conservées tant que votre compte est actif.
                            
                            En cas de suppression de compte, vos données sont effacées dans un délai de 30 jours.
                            """
                        )
                        
                        section(
                            title: "6. Destinataires",
                            content: """
                            Vos données sont uniquement accessibles par :
                            • Les serveurs d'IterCraft (api.itercraft.com)
                            • Le serveur d'authentification Keycloak (authent.itercraft.com)
                            
                            Aucune donnée n'est transmise à des tiers.
                            """
                        )
                        
                        section(
                            title: "7. Vos droits (RGPD)",
                            content: """
                            Conformément au RGPD, vous disposez des droits suivants :
                            
                            • Droit d'accès : consulter vos données
                            • Droit de rectification : corriger vos données
                            • Droit à l'effacement : supprimer vos données
                            • Droit à la portabilité : récupérer vos données
                            • Droit d'opposition : refuser le traitement
                            • Droit de limitation : limiter le traitement
                            
                            Pour exercer ces droits, contactez-nous à : contact@itercraft.com
                            """
                        )
                        
                        section(
                            title: "8. Sécurité",
                            content: """
                            Nous mettons en œuvre des mesures techniques et organisationnelles pour protéger vos données :
                            
                            • Chiffrement HTTPS pour toutes les communications
                            • Authentification OAuth2 avec PKCE
                            • Tokens JWT avec durée de vie limitée
                            • Aucune donnée sensible stockée sur l'appareil
                            """
                        )
                        
                        section(
                            title: "9. Cookies et traceurs",
                            content: """
                            Cette application n'utilise pas de cookies ni de traceurs publicitaires.
                            
                            Seuls les tokens d'authentification nécessaires au fonctionnement de l'app sont stockés temporairement.
                            """
                        )
                        
                        section(
                            title: "10. Modifications",
                            content: """
                            Cette politique de confidentialité peut être modifiée. Toute modification vous sera notifiée via l'application.
                            
                            Dernière mise à jour : 10 février 2026
                            """
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Confidentialité")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// Section de texte
    private func section(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
