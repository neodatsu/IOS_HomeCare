//
//  ActivityTimerAttributes.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import ActivityKit
import Foundation

/// Attributs statiques de la Live Activity
///
/// Ces données ne changent pas pendant la durée de vie de la Live Activity
struct ActivityTimerAttributes: ActivityAttributes {
    
    /// État dynamique de la Live Activity
    ///
    /// Ces données peuvent être mises à jour pendant l'activité
    public struct ContentState: Codable, Hashable {
        /// Date de début de l'activité
        var startDate: Date
        
        /// Indique si le chronomètre est en pause
        var isPaused: Bool
        
        /// Secondes écoulées au moment de la pause (si en pause)
        var pausedElapsedSeconds: Int
    }
    
    /// Code du service (tondeuse, karcher, piscine)
    var serviceCode: String
    
    /// Libellé affiché à l'utilisateur
    var serviceLabel: String
    
    /// Nom de l'icône SF Symbol
    var icon: String
}
