//
//  LegalView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import SwiftUI

/// Vue des mentions légales
///
/// Affiche les mentions légales obligatoires de l'application
struct LegalView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    section(
                        title: "Éditeur",
                        content: """
                        IterCraft
                        Laurent FERRER
                        
                        Contact : contact@itercraft.com
                        """
                    )
                    
                    section(
                        title: "Hébergement",
                        content: """
                        Serveur API : api.itercraft.com
                        Serveur d'authentification : authent.itercraft.com
                        """
                    )
                    
                    section(
                        title: "Propriété intellectuelle",
                        content: """
                        L'application HomeCare et l'ensemble de son contenu (textes, images, code source) sont la propriété exclusive d'IterCraft.
                        
                        Toute reproduction, distribution ou utilisation sans autorisation est interdite.
                        """
                    )
                    
                    section(
                        title: "Données personnelles",
                        content: """
                        Pour toute information concernant le traitement de vos données personnelles, consultez notre Politique de confidentialité.
                        """
                    )
                    
                    section(
                        title: "Responsabilité",
                        content: """
                        IterCraft met tout en œuvre pour fournir un service de qualité mais ne peut garantir l'absence d'erreurs ou d'interruptions.
                        
                        L'utilisateur utilise l'application sous sa propre responsabilité.
                        """
                    )
                    
                    section(
                        title: "Licence",
                        content: """
                        Ce logiciel est distribué sous licence MIT.
                        
                        Copyright © 2026 Laurent FERRER - IterCraft
                        """
                    )
                }
                .padding()
            }
            .navigationTitle("Mentions légales")
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
    LegalView()
}
