//
//  AuthenticationService.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation
import AuthenticationServices
import os.log
import UIKit

/// Service de gestion de l'authentification via Keycloak
///
/// Ce service gère le flux OAuth2/OpenID Connect avec le serveur Keycloak.
/// Il utilise ASWebAuthenticationSession pour une authentification sécurisée
/// via le navigateur système.
///
/// Flux d'authentification:
/// 1. Génération d'un code verifier PKCE
/// 2. Ouverture de la session d'authentification
/// 3. Redirection vers Keycloak
/// 4. Utilisateur s'authentifie
/// 5. Callback avec le code d'autorisation
/// 6. Échange du code contre un access token
/// 7. Récupération des informations utilisateur
@MainActor
@Observable
class AuthenticationService: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    // MARK: - Properties
    
    /// Indique si l'utilisateur est authentifié
    private(set) var isAuthenticated = false
    
    /// Token d'accès JWT
    private(set) var accessToken: String?
    
    /// Token de rafraîchissement
    private(set) var refreshToken: String?
    
    /// Informations sur l'utilisateur connecté
    private(set) var userInfo: UserInfo?
    
    /// Code verifier pour PKCE (Proof Key for Code Exchange)
    private var codeVerifier: String?
    
    /// Indique si on doit forcer une nouvelle authentification (session éphémère)
    private var forceNewLogin = false
    
    /// Logger pour le suivi des opérations d'authentification
    private let logger = Logger(subsystem: "com.itercraft.homecare", category: "Authentication")
    
    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    /// Fournit le contexte de présentation pour la session d'authentification
    ///
    /// Cette méthode est requise par ASWebAuthenticationPresentationContextProviding
    /// et retourne la fenêtre principale de l'application.
    ///
    /// - Parameter session: La session d'authentification
    /// - Returns: La fenêtre de présentation
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Récupérer la fenêtre principale de l'application
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first ?? ASPresentationAnchor()
        return window
    }
    
    // MARK: - Authentication Methods
    
    /// Lance le processus d'authentification
    ///
    /// Cette méthode ouvre une session d'authentification web pour permettre
    /// à l'utilisateur de se connecter via Keycloak.
    ///
    /// - Throws: `AuthenticationError` si l'authentification échoue
    func login() async throws {
        logger.info("🔐 Début de l'authentification")
        
        // Générer le code verifier et challenge PKCE
        let verifier = generateCodeVerifier()
        self.codeVerifier = verifier
        let challenge = generateCodeChallenge(from: verifier)
        
        logger.info("✅ Code PKCE généré")
        
        // Construire l'URL d'autorisation avec tous les paramètres
        guard var urlComponents = URLComponents(url: KeycloakConfig.authorizationURL, resolvingAgainstBaseURL: false) else {
            logger.error("❌ URL d'autorisation invalide")
            throw AuthenticationError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: KeycloakConfig.clientId),
            URLQueryItem(name: "redirect_uri", value: KeycloakConfig.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: KeycloakConfig.scopes),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        
        guard let authURL = urlComponents.url else {
            logger.error("❌ Impossible de construire l'URL d'autorisation")
            throw AuthenticationError.invalidURL
        }
        
        logger.info("🌐 URL d'autorisation: \(authURL.absoluteString)")
        
        // Lancer la session d'authentification
        let callbackURL = try await authenticate(with: authURL)
        logger.info("✅ Callback reçu: \(callbackURL.absoluteString)")
        
        // Extraire le code d'autorisation du callback
        guard let code = extractAuthorizationCode(from: callbackURL) else {
            logger.error("❌ Code d'autorisation non trouvé dans le callback")
            throw AuthenticationError.invalidAuthorizationCode
        }
        
        logger.info("✅ Code d'autorisation reçu")
        
        // Échanger le code contre des tokens
        try await exchangeCodeForTokens(code: code, codeVerifier: verifier)
        
        // Récupérer les informations utilisateur
        try await fetchUserInfo()
        
        logger.info("✅ Authentification réussie pour l'utilisateur: \(self.userInfo?.preferredUsername ?? "inconnu")")
    }
    
    /// Déconnecte l'utilisateur
    ///
    /// Cette méthode efface tous les tokens et informations utilisateur stockés,
    /// et tente de révoquer la session Keycloak côté serveur.
    /// La prochaine connexion nécessitera une nouvelle saisie des identifiants.
    func logout() async {
        logger.info("Déconnexion de l'utilisateur")
        
        // Tenter de révoquer la session côté serveur si on a un refresh token
        if let token = refreshToken {
            await revokeToken(token)
        }
        
        // Effacer les données locales
        accessToken = nil
        refreshToken = nil
        userInfo = nil
        isAuthenticated = false
        codeVerifier = nil
        
        // Forcer une session éphémère lors de la prochaine connexion
        forceNewLogin = true
    }
    
    /// Révoque un token côté serveur Keycloak
    ///
    /// - Parameter token: Token à révoquer (access ou refresh token)
    private func revokeToken(_ token: String) async {
        // Construire l'URL de révocation
        guard let revokeURL = URL(string: "\(KeycloakConfig.baseURL)/realms/\(KeycloakConfig.realm)/protocol/openid-connect/revoke") else {
            logger.error("URL de révocation invalide")
            return
        }
        
        var request = URLRequest(url: revokeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "client_id": KeycloakConfig.clientId,
            "token": token,
            "token_type_hint": "refresh_token"
        ]
        
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                logger.info("Token révoqué avec succès")
            } else {
                logger.warning("Échec de la révocation du token côté serveur")
            }
        } catch {
            logger.error("Erreur lors de la révocation du token: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    
    /// Ouvre la session d'authentification web
    ///
    /// - Parameter url: URL d'autorisation Keycloak
    /// - Returns: URL de callback contenant le code d'autorisation
    /// - Throws: `AuthenticationError.cancelled` si l'utilisateur annule
    private func authenticate(with url: URL) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "itercraft.homecare"
            ) { callbackURL, error in
                if let error = error {
                    let nsError = error as NSError
                    // Code 1 = User cancelled
                    if nsError.code == 1 {
                        continuation.resume(throwing: AuthenticationError.cancelled)
                    } else {
                        continuation.resume(throwing: AuthenticationError.authenticationFailed(error))
                    }
                    return
                }
                
                guard let callbackURL = callbackURL else {
                    continuation.resume(throwing: AuthenticationError.invalidCallback)
                    return
                }
                
                continuation.resume(returning: callbackURL)
            }
            
            // IMPORTANT : Définir le presentation context provider
            session.presentationContextProvider = self
            
            // Utiliser une session éphémère si on force une nouvelle connexion
            // Cela vide les cookies et force la redemande des identifiants
            session.prefersEphemeralWebBrowserSession = self.forceNewLogin
            
            // Réinitialiser le flag après utilisation
            if self.forceNewLogin {
                self.forceNewLogin = false
            }
            
            // Démarrer la session (on ne vérifie pas le retour car il peut être faux même si ça marche)
            session.start()
        }
    }
    
    /// Extrait le code d'autorisation de l'URL de callback
    ///
    /// - Parameter url: URL de callback
    /// - Returns: Code d'autorisation ou nil si non trouvé
    private func extractAuthorizationCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        return code
    }
    
    /// Échange le code d'autorisation contre des tokens d'accès
    ///
    /// - Parameters:
    ///   - code: Code d'autorisation reçu de Keycloak
    ///   - codeVerifier: Code verifier PKCE
    /// - Throws: `AuthenticationError` si l'échange échoue
    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws {
        var request = URLRequest(url: KeycloakConfig.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyParameters = [
            "grant_type": "authorization_code",
            "client_id": KeycloakConfig.clientId,
            "code": code,
            "redirect_uri": KeycloakConfig.redirectURI,
            "code_verifier": codeVerifier
        ]
        
        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AuthenticationError.tokenExchangeFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        self.accessToken = tokenResponse.accessToken
        self.refreshToken = tokenResponse.refreshToken
        self.isAuthenticated = true
        
        logger.info("Tokens récupérés avec succès")
    }
    
    /// Récupère les informations de l'utilisateur connecté
    ///
    /// - Throws: `AuthenticationError` si la récupération échoue
    private func fetchUserInfo() async throws {
        guard let token = accessToken else {
            throw AuthenticationError.noAccessToken
        }
        
        var request = URLRequest(url: KeycloakConfig.userInfoURL)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AuthenticationError.userInfoFetchFailed
        }
        
        self.userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
        logger.info("Informations utilisateur récupérées")
    }
    
    // MARK: - PKCE Methods
    
    /// Génère un code verifier aléatoire pour PKCE
    ///
    /// - Returns: String aléatoire de 43 à 128 caractères
    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
    /// Génère le code challenge à partir du code verifier
    ///
    /// - Parameter verifier: Code verifier
    /// - Returns: Code challenge SHA256 encodé en base64
    private func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else {
            return ""
        }
        
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
        }
        
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Models

/// Réponse de l'endpoint token de Keycloak
private struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

/// Informations sur l'utilisateur connecté
struct UserInfo: Codable {
    let sub: String
    let email: String?
    let emailVerified: Bool?
    let name: String?
    let preferredUsername: String?
    let givenName: String?
    let familyName: String?
    
    enum CodingKeys: String, CodingKey {
        case sub
        case email
        case emailVerified = "email_verified"
        case name
        case preferredUsername = "preferred_username"
        case givenName = "given_name"
        case familyName = "family_name"
    }
}

// MARK: - Errors

/// Erreurs possibles lors de l'authentification
enum AuthenticationError: LocalizedError {
    case invalidURL
    case cancelled
    case authenticationFailed(Error)
    case invalidCallback
    case invalidAuthorizationCode
    case tokenExchangeFailed
    case noAccessToken
    case userInfoFetchFailed
    case sessionStartFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "L'URL d'authentification est invalide"
        case .cancelled:
            return "L'authentification a été annulée"
        case .authenticationFailed(let error):
            return "Échec de l'authentification : \(error.localizedDescription)"
        case .invalidCallback:
            return "URL de callback invalide"
        case .invalidAuthorizationCode:
            return "Code d'autorisation invalide"
        case .tokenExchangeFailed:
            return "Échec de l'échange du code contre les tokens"
        case .noAccessToken:
            return "Aucun token d'accès disponible"
        case .userInfoFetchFailed:
            return "Échec de la récupération des informations utilisateur"
        case .sessionStartFailed:
            return "Impossible de démarrer la session d'authentification"
        }
    }
}

// MARK: - CommonCrypto Import

import CommonCrypto
