//
//  ConsentManager.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation

/// Gestionnaire du consentement RGPD
///
/// Gère la persistance et la vérification du consentement utilisateur
/// pour le traitement des données personnelles.
@Observable
@MainActor
class ConsentManager {
    
    // MARK: - Properties
    
    /// Clé UserDefaults pour le consentement
    private let consentKey = "user_has_given_consent"
    
    /// Clé UserDefaults pour la date du consentement
    private let consentDateKey = "consent_date"
    
    /// Indique si l'utilisateur a donné son consentement
    private(set) var hasGivenConsent: Bool
    
    /// Date à laquelle le consentement a été donné
    private(set) var consentDate: Date?
    
    // MARK: - Initialization
    
    /// Initialise le gestionnaire et charge l'état du consentement
    init() {
        self.hasGivenConsent = UserDefaults.standard.bool(forKey: consentKey)
        
        if let timestamp = UserDefaults.standard.object(forKey: consentDateKey) as? TimeInterval {
            self.consentDate = Date(timeIntervalSince1970: timestamp)
        }
    }
    
    // MARK: - Public Methods
    
    /// Enregistre le consentement de l'utilisateur
    func giveConsent() {
        hasGivenConsent = true
        consentDate = Date()
        
        UserDefaults.standard.set(true, forKey: consentKey)
        UserDefaults.standard.set(consentDate?.timeIntervalSince1970, forKey: consentDateKey)
    }
    
    /// Révoque le consentement de l'utilisateur
    func revokeConsent() {
        hasGivenConsent = false
        consentDate = nil
        
        UserDefaults.standard.removeObject(forKey: consentKey)
        UserDefaults.standard.removeObject(forKey: consentDateKey)
    }
    
    /// Réinitialise complètement le consentement
    func reset() {
        revokeConsent()
    }
}
