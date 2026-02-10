//
//  Activity.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation

/// Représente une activité de maintenance
///
/// Une activité correspond à une tâche de maintenance (tondeuse, karcher, piscine, etc.)
/// avec son état actuel (active/inactive) et le temps passé aujourd'hui.
///
/// Cette entité du domaine suit les principes DDD (Domain-Driven Development).
struct Activity: Identifiable, Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    /// Identifiant unique basé sur le code du service
    var id: String { serviceCode }
    
    /// Code unique du service (ex: "tondeuse", "karcher", "piscine")
    let serviceCode: String
    
    /// Libellé descriptif du service (ex: "Passer la tondeuse")
    let serviceLabel: String
    
    /// Indique si l'activité est actuellement active (en cours)
    let isActive: Bool
    
    /// Date et heure de début de l'activité en cours (nil si inactive)
    let startedAt: Date?
    
    /// Nombre total de minutes passées sur cette activité aujourd'hui
    let totalMinutesToday: Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case serviceCode
        case serviceLabel
        case isActive
        case startedAt
        case totalMinutesToday
    }
    
    // MARK: - Computed Properties
    
    /// Temps formaté en heures et minutes (ex: "1h 30min")
    var formattedTime: String {
        let hours = totalMinutesToday / 60
        let minutes = totalMinutesToday % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)min"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)min"
        } else {
            return "0min"
        }
    }
    
    /// Icône SF Symbol recommandée pour l'activité
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
}

// MARK: - Sample Data

extension Activity {
    /// Données d'exemple pour les previews et tests
    static let samples: [Activity] = [
        Activity(
            serviceCode: "tondeuse",
            serviceLabel: "Passer la tondeuse",
            isActive: false,
            startedAt: nil,
            totalMinutesToday: 0
        ),
        Activity(
            serviceCode: "karcher",
            serviceLabel: "Passer le Karcher",
            isActive: true,
            startedAt: Date().addingTimeInterval(-3600), // Il y a 1h
            totalMinutesToday: 60
        ),
        Activity(
            serviceCode: "piscine",
            serviceLabel: "Nettoyer la piscine",
            isActive: false,
            startedAt: nil,
            totalMinutesToday: 45
        )
    ]
}
