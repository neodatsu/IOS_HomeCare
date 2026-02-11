//
//  TimerManager.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import Foundation
import Observation
import ActivityKit
import os.log

@MainActor
@Observable
final class TimerManager {
    
    static let shared = TimerManager()
    
    var startDate: Date?
    var activeServiceCode: String?
    var activeServiceLabel: String?
    var activeServiceIcon: String?
    var isPaused: Bool = false
    var pausedElapsedSeconds: Int = 0
    
    private var pauseDate: Date?
    private let logger = Logger(subsystem: "com.itercraft.homecare", category: "Timer")
    
    /// Référence vers la Live Activity active
    private var currentActivity: ActivityKit.Activity<ActivityTimerAttributes>?
    
    private init() {
        restoreState()
    }
    
    var elapsedSeconds: Int {
        guard let startDate = startDate else { return 0 }
        if isPaused { return pausedElapsedSeconds }
        return Int(Date().timeIntervalSince(startDate))
    }
    
    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var isActive: Bool {
        startDate != nil && activeServiceCode != nil
    }
    
    func startActivity(serviceCode: String, serviceLabel: String? = nil, icon: String? = nil, startDate: Date = Date()) {
        logger.info("▶️ Démarrage du chronomètre pour \(serviceCode)")
        logger.info("📅 startDate reçue: \(startDate)")
        
        self.startDate = startDate
        self.activeServiceCode = serviceCode
        self.activeServiceLabel = serviceLabel ?? serviceCode
        self.activeServiceIcon = icon ?? iconForServiceCode(serviceCode)
        self.isPaused = false
        self.pausedElapsedSeconds = 0
        self.pauseDate = nil
        saveState()
        
        // Démarrer la Live Activity
        startLiveActivity()
        
        logger.info("✅ Activité démarrée")
        logger.info("📊 État après démarrage:")
        logger.info("   - self.startDate: \(String(describing: self.startDate))")
        logger.info("   - elapsedSeconds: \(self.elapsedSeconds)")
        logger.info("   - formattedTime: \(self.formattedTime)")
    }
    
    func stopActivity() {
        logger.info("⏹️ Arrêt du chronomètre")
        
        // Arrêter la Live Activity
        stopLiveActivity()
        
        self.startDate = nil
        self.activeServiceCode = nil
        self.activeServiceLabel = nil
        self.activeServiceIcon = nil
        self.isPaused = false
        self.pausedElapsedSeconds = 0
        self.pauseDate = nil
        saveState()
        logger.info("✅ Activité arrêtée")
    }
    
    func pause() {
        guard !isPaused, let startDate = startDate else { return }
        logger.info("⏸️ Mise en pause")
        isPaused = true
        pausedElapsedSeconds = Int(Date().timeIntervalSince(startDate))
        pauseDate = Date()
        saveState()
        
        // Mettre à jour la Live Activity
        updateLiveActivity()
        
        logger.info("✅ En pause")
    }
    
    func resume() {
        guard isPaused, let pauseDate = pauseDate else { return }
        logger.info("▶️ Reprise")
        let pauseDuration = Date().timeIntervalSince(pauseDate)
        if let currentStartDate = startDate {
            startDate = currentStartDate.addingTimeInterval(pauseDuration)
        }
        isPaused = false
        self.pauseDate = nil
        saveState()
        
        // Mettre à jour la Live Activity
        updateLiveActivity()
        
        logger.info("✅ Reprise")
    }
    
    private enum Keys {
        static let startDate = "ActivityTimer.startDate"
        static let serviceCode = "ActivityTimer.serviceCode"
        static let serviceLabel = "ActivityTimer.serviceLabel"
        static let serviceIcon = "ActivityTimer.serviceIcon"
        static let isPaused = "ActivityTimer.isPaused"
        static let pausedElapsedSeconds = "ActivityTimer.pausedElapsedSeconds"
        static let pauseDate = "ActivityTimer.pauseDate"
    }
    
    private func saveState() {
        let defaults = UserDefaults.standard
        if let startDate = startDate {
            defaults.set(startDate, forKey: Keys.startDate)
        } else {
            defaults.removeObject(forKey: Keys.startDate)
        }
        if let serviceCode = activeServiceCode {
            defaults.set(serviceCode, forKey: Keys.serviceCode)
        } else {
            defaults.removeObject(forKey: Keys.serviceCode)
        }
        if let serviceLabel = activeServiceLabel {
            defaults.set(serviceLabel, forKey: Keys.serviceLabel)
        } else {
            defaults.removeObject(forKey: Keys.serviceLabel)
        }
        if let serviceIcon = activeServiceIcon {
            defaults.set(serviceIcon, forKey: Keys.serviceIcon)
        } else {
            defaults.removeObject(forKey: Keys.serviceIcon)
        }
        defaults.set(isPaused, forKey: Keys.isPaused)
        defaults.set(pausedElapsedSeconds, forKey: Keys.pausedElapsedSeconds)
        if let pauseDate = pauseDate {
            defaults.set(pauseDate, forKey: Keys.pauseDate)
        } else {
            defaults.removeObject(forKey: Keys.pauseDate)
        }
    }
    
    private func restoreState() {
        let defaults = UserDefaults.standard
        startDate = defaults.object(forKey: Keys.startDate) as? Date
        activeServiceCode = defaults.string(forKey: Keys.serviceCode)
        activeServiceLabel = defaults.string(forKey: Keys.serviceLabel)
        activeServiceIcon = defaults.string(forKey: Keys.serviceIcon)
        isPaused = defaults.bool(forKey: Keys.isPaused)
        pausedElapsedSeconds = defaults.integer(forKey: Keys.pausedElapsedSeconds)
        pauseDate = defaults.object(forKey: Keys.pauseDate) as? Date
        if isActive {
            logger.info("🔄 État restauré")
        }
    }
    
    private func iconForServiceCode(_ code: String) -> String {
        switch code.lowercased() {
        case "tondeuse": return "leaf.fill"
        case "karcher": return "drop.fill"
        case "piscine": return "water.waves"
        default: return "wrench.and.screwdriver.fill"
        }
    }
    
    // MARK: - Live Activity Management
    
    /// Démarre la Live Activity
    private func startLiveActivity() {
        logger.info("🚀 Tentative de démarrage Live Activity...")
        
        let authInfo = ActivityAuthorizationInfo()
        logger.info("📱 areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            logger.warning("⚠️ Live Activities non autorisées")
            logger.warning("⚠️ Vérifiez Info.plist et Réglages > Notifications > HomeCare")
            return
        }
        
        guard let serviceCode = self.activeServiceCode,
              let serviceLabel = self.activeServiceLabel,
              let icon = self.activeServiceIcon,
              let startDate = self.startDate else {
            logger.error("❌ Impossible de démarrer la Live Activity: données manquantes")
            logger.error("   - serviceCode: \(String(describing: self.activeServiceCode))")
            logger.error("   - serviceLabel: \(String(describing: self.activeServiceLabel))")
            logger.error("   - icon: \(String(describing: self.activeServiceIcon))")
            logger.error("   - startDate: \(String(describing: self.startDate))")
            return
        }
        
        logger.info("📦 Création des attributs...")
        let attributes = ActivityTimerAttributes(
            serviceCode: serviceCode,
            serviceLabel: serviceLabel,
            icon: icon
        )
        
        logger.info("📦 Création du state...")
        let contentState = ActivityTimerAttributes.ContentState(
            startDate: startDate,
            isPaused: false,
            pausedElapsedSeconds: 0
        )
        
        do {
            logger.info("🎯 Appel de Activity.request()...")
            let activity = try ActivityKit.Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            logger.info("✅ Live Activity démarrée: \(activity.id)")
            logger.info("🎉 Devrait apparaître sur l'écran verrouillé!")
        } catch {
            logger.error("❌ Erreur démarrage Live Activity: \(error.localizedDescription)")
            logger.error("❌ Type d'erreur: \(String(describing: type(of: error)))")
            logger.error("❌ Détails: \(error)")
        }
    }
    
    /// Met à jour la Live Activity (pause/reprise)
    private func updateLiveActivity() {
        guard let activity = currentActivity,
              let startDate = startDate else {
            logger.warning("⚠️ Pas de Live Activity à mettre à jour")
            return
        }
        
        let contentState = ActivityTimerAttributes.ContentState(
            startDate: startDate,
            isPaused: isPaused,
            pausedElapsedSeconds: pausedElapsedSeconds
        )
        
        Task {
            await activity.update(
                ActivityContent(state: contentState, staleDate: nil)
            )
            logger.info("✅ Live Activity mise à jour")
        }
    }
    
    /// Arrête la Live Activity
    private func stopLiveActivity() {
        guard let activity = currentActivity else {
            logger.info("ℹ️ Pas de Live Activity à arrêter")
            return
        }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            logger.info("✅ Live Activity terminée")
        }
    }
}
