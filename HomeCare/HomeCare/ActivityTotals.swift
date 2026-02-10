//
//  ActivityTotals.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation

/// Récapitulatif des temps d'exécution des activités
///
/// Cette structure contient les totaux globaux et par activité
/// pour différentes périodes (jour, semaine, mois, année).
///
/// Architecture: Entité du domaine (DDD)
struct ActivityTotals: Codable, Equatable {
    
    // MARK: - Global Totals
    
    /// Minutes totales aujourd'hui (toutes activités confondues)
    let todayMinutes: Int
    
    /// Minutes totales cette semaine (toutes activités confondues)
    let weekMinutes: Int
    
    /// Minutes totales ce mois (toutes activités confondues)
    let monthMinutes: Int
    
    /// Minutes totales cette année (toutes activités confondues)
    let yearMinutes: Int
    
    /// Détails par activité
    let byActivity: [ActivityTotal]
    
    // MARK: - Computed Properties
    
    /// Temps formaté pour aujourd'hui
    var formattedToday: String {
        formatMinutes(todayMinutes)
    }
    
    /// Temps formaté pour la semaine
    var formattedWeek: String {
        formatMinutes(weekMinutes)
    }
    
    /// Temps formaté pour le mois
    var formattedMonth: String {
        formatMinutes(monthMinutes)
    }
    
    /// Temps formaté pour l'année
    var formattedYear: String {
        formatMinutes(yearMinutes)
    }
    
    // MARK: - Private Methods
    
    /// Formate des minutes en heures et minutes
    ///
    /// - Parameter minutes: Nombre de minutes
    /// - Returns: Chaîne formatée (ex: "2h 30min", "45min", "0min")
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)min"
        } else if hours > 0 {
            return "\(hours)h"
        } else if mins > 0 {
            return "\(mins)min"
        } else {
            return "0min"
        }
    }
}

/// Total d'une activité spécifique sur différentes périodes
struct ActivityTotal: Codable, Equatable, Identifiable {
    
    // MARK: - Properties
    
    /// Identifiant unique basé sur le code du service
    var id: String { serviceCode }
    
    /// Code unique du service
    let serviceCode: String
    
    /// Libellé descriptif du service
    let serviceLabel: String
    
    /// Minutes aujourd'hui pour cette activité
    let todayMinutes: Int
    
    /// Minutes cette semaine pour cette activité
    let weekMinutes: Int
    
    /// Minutes ce mois pour cette activité
    let monthMinutes: Int
    
    /// Minutes cette année pour cette activité
    let yearMinutes: Int
    
    // MARK: - Computed Properties
    
    /// Temps formaté pour aujourd'hui
    var formattedToday: String {
        formatMinutes(todayMinutes)
    }
    
    /// Temps formaté pour la semaine
    var formattedWeek: String {
        formatMinutes(weekMinutes)
    }
    
    /// Temps formaté pour le mois
    var formattedMonth: String {
        formatMinutes(monthMinutes)
    }
    
    /// Temps formaté pour l'année
    var formattedYear: String {
        formatMinutes(yearMinutes)
    }
    
    /// Icône SF Symbol pour l'activité
    var icon: String {
        switch serviceCode.lowercased() {
        case "tondeuse":
            return "leaf.fill"
        case "karcher":
            return "drop.fill"
        case "piscine":
            return "water.waves"
        default:
            return "wrench.and.screwdriver.fill"
        }
    }
    
    // MARK: - Private Methods
    
    /// Formate des minutes en heures et minutes
    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        
        if hours > 0 && mins > 0 {
            return "\(hours)h \(mins)min"
        } else if hours > 0 {
            return "\(hours)h"
        } else if mins > 0 {
            return "\(mins)min"
        } else {
            return "0min"
        }
    }
}

// MARK: - Sample Data

extension ActivityTotals {
    /// Données d'exemple pour les previews et tests
    static let sample = ActivityTotals(
        todayMinutes: 125,
        weekMinutes: 480,
        monthMinutes: 1890,
        yearMinutes: 12500,
        byActivity: [
            ActivityTotal(
                serviceCode: "tondeuse",
                serviceLabel: "Passer la tondeuse",
                todayMinutes: 45,
                weekMinutes: 180,
                monthMinutes: 720,
                yearMinutes: 5000
            ),
            ActivityTotal(
                serviceCode: "karcher",
                serviceLabel: "Passer le Karcher",
                todayMinutes: 30,
                weekMinutes: 120,
                monthMinutes: 480,
                yearMinutes: 3500
            ),
            ActivityTotal(
                serviceCode: "piscine",
                serviceLabel: "Nettoyer la piscine",
                todayMinutes: 50,
                weekMinutes: 180,
                monthMinutes: 690,
                yearMinutes: 4000
            )
        ]
    )
}
