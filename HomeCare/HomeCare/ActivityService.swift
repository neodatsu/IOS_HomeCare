//
//  ActivityService.swift
//  HomeCare
//
//  Created by Laurent FERRER on 10/02/2026.
//

import Foundation
import os.log

/// Service de gestion des activités de maintenance
///
/// Ce service gère les appels API pour récupérer, créer et mettre à jour
/// les activités de maintenance depuis l'API IterCraft.
///
/// Architecture: Couche Infrastructure dans le pattern DDD
@MainActor
@Observable
class ActivityService {
    
    // MARK: - Properties
    
    /// Liste des activités chargées depuis l'API
    private(set) var activities: [Activity] = []
    
    /// Totaux des temps d'exécution
    private(set) var totals: ActivityTotals?
    
    /// Indique si un chargement est en cours
    private(set) var isLoading = false
    
    /// Indique si le chargement des totaux est en cours
    private(set) var isLoadingTotals = false
    
    /// Erreur éventuelle lors des opérations
    private(set) var error: ActivityError?
    
    /// Service d'authentification pour récupérer le token
    private let authService: AuthenticationService
    
    /// Logger pour le suivi des opérations
    private let logger = Logger(subsystem: "com.itercraft.homecare", category: "Activities")
    
    // MARK: - Constants
    
    /// URL de base de l'API IterCraft
    private let baseURL = "https://api.itercraft.com"
    
    // MARK: - Initialization
    
    /// Initialise le service d'activités
    ///
    /// - Parameter authService: Service d'authentification pour récupérer le token
    init(authService: AuthenticationService) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    /// Charge la liste des activités depuis l'API
    ///
    /// Cette méthode effectue un appel GET sur /api/maintenance/activities
    /// avec le token d'authentification Bearer.
    ///
    /// - Throws: `ActivityError` si le chargement échoue
    func loadActivities() async throws {
        logger.info("🔄 Chargement des activités...")
        
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        // Vérifier qu'on a un token d'accès
        guard let token = authService.accessToken else {
            logger.error("❌ Pas de token d'accès disponible")
            let err = ActivityError.notAuthenticated
            error = err
            throw err
        }
        
        // Construire l'URL de l'endpoint
        guard let url = URL(string: "\(baseURL)/api/maintenance/activities") else {
            logger.error("❌ URL invalide")
            let err = ActivityError.invalidURL
            error = err
            throw err
        }
        
        // Créer la requête avec le token Bearer
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        logger.info("🌐 Requête: GET \(url.absoluteString)")
        
        do {
            // Effectuer la requête
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérifier le code de statut HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Réponse HTTP invalide")
                let err = ActivityError.invalidResponse
                error = err
                throw err
            }
            
            logger.info("📡 Code HTTP: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ Erreur HTTP: \(httpResponse.statusCode)")
                
                // Gérer les cas d'erreur spécifiques
                if httpResponse.statusCode == 401 {
                    let err = ActivityError.unauthorized
                    error = err
                    throw err
                } else if httpResponse.statusCode == 404 {
                    let err = ActivityError.notFound
                    error = err
                    throw err
                } else {
                    let err = ActivityError.serverError(httpResponse.statusCode)
                    error = err
                    throw err
                }
            }
            
            // Décoder le JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let loadedActivities = try decoder.decode([Activity].self, from: data)
            
            // Mettre à jour la liste
            self.activities = loadedActivities
            
            logger.info("✅ \(loadedActivities.count) activités chargées")
            
        } catch let decodingError as DecodingError {
            logger.error("❌ Erreur de décodage JSON: \(decodingError.localizedDescription)")
            let err = ActivityError.decodingFailed(decodingError)
            error = err
            throw err
        } catch let activityError as ActivityError {
            // Re-throw les erreurs déjà typées
            throw activityError
        } catch {
            logger.error("❌ Erreur réseau: \(error.localizedDescription)")
            let err = ActivityError.networkError(error)
            self.error = err
            throw err
        }
    }
    
    /// Recharge les activités (alias pour loadActivities)
    func refresh() async throws {
        try await loadActivities()
    }
    
    /// Charge les totaux des temps d'exécution depuis l'API
    ///
    /// Cette méthode effectue un appel GET sur /api/maintenance/totals
    /// avec le token d'authentification Bearer.
    ///
    /// - Throws: `ActivityError` si le chargement échoue
    func loadTotals() async throws {
        logger.info("🔄 Chargement des totaux...")
        
        isLoadingTotals = true
        error = nil
        
        defer {
            isLoadingTotals = false
        }
        
        // Vérifier qu'on a un token d'accès
        guard let token = authService.accessToken else {
            logger.error("❌ Pas de token d'accès disponible")
            let err = ActivityError.notAuthenticated
            error = err
            throw err
        }
        
        // Construire l'URL de l'endpoint
        guard let url = URL(string: "\(baseURL)/api/maintenance/totals") else {
            logger.error("❌ URL invalide")
            let err = ActivityError.invalidURL
            error = err
            throw err
        }
        
        // Créer la requête avec le token Bearer
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        logger.info("🌐 Requête: GET \(url.absoluteString)")
        
        do {
            // Effectuer la requête
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Vérifier le code de statut HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Réponse HTTP invalide")
                let err = ActivityError.invalidResponse
                error = err
                throw err
            }
            
            logger.info("📡 Code HTTP: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ Erreur HTTP: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    let err = ActivityError.unauthorized
                    error = err
                    throw err
                } else if httpResponse.statusCode == 404 {
                    let err = ActivityError.notFound
                    error = err
                    throw err
                } else {
                    let err = ActivityError.serverError(httpResponse.statusCode)
                    error = err
                    throw err
                }
            }
            
            // Décoder le JSON
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let loadedTotals = try decoder.decode(ActivityTotals.self, from: data)
            
            // Mettre à jour les totaux
            self.totals = loadedTotals
            
            logger.info("✅ Totaux chargés - Aujourd'hui: \(loadedTotals.todayMinutes)min, Semaine: \(loadedTotals.weekMinutes)min")
            
        } catch let decodingError as DecodingError {
            logger.error("❌ Erreur de décodage JSON: \(decodingError.localizedDescription)")
            let err = ActivityError.decodingFailed(decodingError)
            error = err
            throw err
        } catch let activityError as ActivityError {
            throw activityError
        } catch {
            logger.error("❌ Erreur réseau: \(error.localizedDescription)")
            let err = ActivityError.networkError(error)
            self.error = err
            throw err
        }
    }
    
    /// Charge les activités ET les totaux en parallèle
    func loadAll() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.loadActivities()
            }
            group.addTask {
                try await self.loadTotals()
            }
            try await group.waitForAll()
        }
    }
    
    /// Démarre une activité
    ///
    /// Cette méthode effectue un appel POST sur /api/maintenance/activities/{serviceCode}/start
    /// pour démarrer le chronomètre d'une activité.
    ///
    /// - Parameter serviceCode: Code du service à démarrer
    /// - Throws: `ActivityError` si le démarrage échoue
    func startActivity(serviceCode: String) async throws {
        logger.info("▶️ Démarrage de l'activité: \(serviceCode)")
        
        // Vérifier qu'on a un token d'accès
        guard let token = authService.accessToken else {
            logger.error("❌ Pas de token d'accès disponible")
            throw ActivityError.notAuthenticated
        }
        
        // Construire l'URL de l'endpoint
        guard let url = URL(string: "\(baseURL)/api/maintenance/activities/\(serviceCode)/start") else {
            logger.error("❌ URL invalide")
            throw ActivityError.invalidURL
        }
        
        // Créer la requête POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        logger.info("🌐 Requête: POST \(url.absoluteString)")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Réponse HTTP invalide")
                throw ActivityError.invalidResponse
            }
            
            logger.info("📡 Code HTTP: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ Erreur HTTP: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    throw ActivityError.unauthorized
                } else {
                    throw ActivityError.serverError(httpResponse.statusCode)
                }
            }
            
            logger.info("✅ Activité \(serviceCode) démarrée")
            
            // Recharger les activités pour mettre à jour l'état
            try await loadActivities()
            
        } catch let activityError as ActivityError {
            throw activityError
        } catch {
            logger.error("❌ Erreur réseau: \(error.localizedDescription)")
            throw ActivityError.networkError(error)
        }
    }
    
    /// Arrête une activité
    ///
    /// Cette méthode effectue un appel POST sur /api/maintenance/activities/{serviceCode}/stop
    /// pour arrêter le chronomètre d'une activité.
    ///
    /// - Parameter serviceCode: Code du service à arrêter
    /// - Throws: `ActivityError` si l'arrêt échoue
    func stopActivity(serviceCode: String) async throws {
        logger.info("⏹️ Arrêt de l'activité: \(serviceCode)")
        
        // Vérifier qu'on a un token d'accès
        guard let token = authService.accessToken else {
            logger.error("❌ Pas de token d'accès disponible")
            throw ActivityError.notAuthenticated
        }
        
        // Construire l'URL de l'endpoint
        guard let url = URL(string: "\(baseURL)/api/maintenance/activities/\(serviceCode)/stop") else {
            logger.error("❌ URL invalide")
            throw ActivityError.invalidURL
        }
        
        // Créer la requête POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        logger.info("🌐 Requête: POST \(url.absoluteString)")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Réponse HTTP invalide")
                throw ActivityError.invalidResponse
            }
            
            logger.info("📡 Code HTTP: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ Erreur HTTP: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    throw ActivityError.unauthorized
                } else {
                    throw ActivityError.serverError(httpResponse.statusCode)
                }
            }
            
            logger.info("✅ Activité \(serviceCode) arrêtée")
            
            // Recharger les activités ET les totaux pour mettre à jour les statistiques
            try await loadAll()
            
        } catch let activityError as ActivityError {
            throw activityError
        } catch {
            logger.error("❌ Erreur réseau: \(error.localizedDescription)")
            throw ActivityError.networkError(error)
        }
    }
}

// MARK: - Errors

/// Erreurs possibles lors des opérations sur les activités
enum ActivityError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case invalidResponse
    case unauthorized
    case notFound
    case serverError(Int)
    case decodingFailed(DecodingError)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Non authentifié. Veuillez vous reconnecter."
        case .invalidURL:
            return "URL de l'API invalide"
        case .invalidResponse:
            return "Réponse du serveur invalide"
        case .unauthorized:
            return "Non autorisé. Votre session a peut-être expiré."
        case .notFound:
            return "Ressource non trouvée"
        case .serverError(let code):
            return "Erreur serveur (code \(code))"
        case .decodingFailed(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated, .unauthorized:
            return "Veuillez vous reconnecter à l'application."
        case .networkError:
            return "Vérifiez votre connexion internet et réessayez."
        case .serverError:
            return "Le serveur rencontre des difficultés. Réessayez plus tard."
        default:
            return "Réessayez ou contactez le support."
        }
    }
}
