//
//  KeycloakConfig.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation

/// Configuration pour l'authentification Keycloak
///
/// Cette structure contient tous les paramètres nécessaires pour se connecter
/// au serveur Keycloak d'IterCraft via OAuth2/OpenID Connect.
///
/// Serveur: https://authent.itercraft.com/
/// Realm: itercraft
/// Client ID: iterapp
struct KeycloakConfig {
    
    // MARK: - Properties
    
    /// URL de base du serveur Keycloak
    static let baseURL = "https://authent.itercraft.com"
    
    /// Nom du realm Keycloak
    static let realm = "itercraft"
    
    /// Identifiant du client OAuth2
    static let clientId = "iterapp"
    
    /// URL de redirection après authentification
    /// Format: {bundle-id}://oauth-callback
    static let redirectURI = "itercraft.homecare://oauth-callback"
    
    /// Scopes OAuth2 demandés
    static let scopes = "openid profile email"
    
    // MARK: - Computed URLs
    
    /// URL complète de l'endpoint d'autorisation
    /// Format: {baseURL}/realms/{realm}/protocol/openid-connect/auth
    static var authorizationURL: URL {
        URL(string: "\(baseURL)/realms/\(realm)/protocol/openid-connect/auth")!
    }
    
    /// URL complète de l'endpoint de token
    /// Format: {baseURL}/realms/{realm}/protocol/openid-connect/token
    static var tokenURL: URL {
        URL(string: "\(baseURL)/realms/\(realm)/protocol/openid-connect/token")!
    }
    
    /// URL complète de l'endpoint de logout
    /// Format: {baseURL}/realms/{realm}/protocol/openid-connect/logout
    static var logoutURL: URL {
        URL(string: "\(baseURL)/realms/\(realm)/protocol/openid-connect/logout")!
    }
    
    /// URL complète de l'endpoint userinfo
    /// Format: {baseURL}/realms/{realm}/protocol/openid-connect/userinfo
    static var userInfoURL: URL {
        URL(string: "\(baseURL)/realms/\(realm)/protocol/openid-connect/userinfo")!
    }
}
