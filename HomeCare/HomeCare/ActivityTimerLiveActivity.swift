//
//  ActivityTimerLiveActivity.swift
//  HomeCare
//

import ActivityKit
import SwiftUI
import WidgetKit
import AppIntents

// MARK: - Live Activity Widget

/// Interface de la Live Activity pour le chronomètre
struct ActivityTimerLiveActivity: Widget {
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityTimerAttributes.self) { context in
            // Vue de l'écran verrouillé
            LockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(.systemBackground).opacity(0.3))
                .activitySystemActionForegroundColor(.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Vue étendue de la Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Image(systemName: context.attributes.icon)
                            .foregroundColor(context.state.isPaused ? .orange : .green)
                        
                        Text(context.attributes.serviceLabel)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    TimerView(context: context)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        // Bouton Pause/Reprendre
                        Button(intent: TogglePauseIntent()) {
                            Label(
                                context.state.isPaused ? "Reprendre" : "Pause",
                                systemImage: context.state.isPaused ? "play.circle.fill" : "pause.circle.fill"
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                        }
                        .tint(context.state.isPaused ? .green : .orange)
                        
                        // Bouton Stop
                        Button(intent: StopActivityIntent()) {
                            Label("Stop", systemImage: "stop.circle.fill")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .tint(.red)
                    }
                    .padding(.top, 8)
                }
                
            } compactLeading: {
                Image(systemName: context.attributes.icon)
                    .foregroundColor(context.state.isPaused ? .orange : .green)
                
            } compactTrailing: {
                CompactTimerView(context: context)
                    .font(.caption2)
                    .monospacedDigit()
                
            } minimal: {
                Image(systemName: context.attributes.icon)
                    .foregroundColor(context.state.isPaused ? .orange : .green)
            }
        }
    }
}

// MARK: - Lock Screen View

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ActivityTimerAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: context.attributes.icon)
                    .font(.title2)
                    .foregroundColor(context.state.isPaused ? .orange : .green)
                
                Text(context.attributes.serviceLabel)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.isPaused ? "En pause" : "En cours")
                        .font(.caption)
                        .foregroundColor(context.state.isPaused ? .orange : .green)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                TimerView(context: context)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .monospacedDigit()
            }
            
            HStack(spacing: 12) {
                Button(intent: TogglePauseIntent()) {
                    HStack(spacing: 6) {
                        Image(systemName: context.state.isPaused ? "play.circle.fill" : "pause.circle.fill")
                        Text(context.state.isPaused ? "Reprendre" : "Pause")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill((context.state.isPaused ? Color.green : Color.orange).opacity(0.2))
                    )
                }
                .tint(context.state.isPaused ? .green : .orange)
                
                Button(intent: StopActivityIntent()) {
                    HStack(spacing: 6) {
                        Image(systemName: "stop.circle.fill")
                        Text("Stop")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.2))
                    )
                }
                .tint(.red)
            }
        }
        .padding(16)
    }
}

// MARK: - Timer Views

private struct TimerView: View {
    let context: ActivityViewContext<ActivityTimerAttributes>
    
    var body: some View {
        if context.state.isPaused {
            Text(formattedTime(seconds: context.state.pausedElapsedSeconds))
                .foregroundColor(.orange)
        } else {
            Text(timerInterval: context.state.startDate...Date.distantFuture, countsDown: false)
                .foregroundColor(.green)
        }
    }
}

private struct CompactTimerView: View {
    let context: ActivityViewContext<ActivityTimerAttributes>
    
    var body: some View {
        if context.state.isPaused {
            Text(shortFormattedTime(seconds: context.state.pausedElapsedSeconds))
                .foregroundColor(.orange)
        } else {
            Text(timerInterval: context.state.startDate...Date.distantFuture, countsDown: false)
                .foregroundColor(.green)
        }
    }
}

// MARK: - Helper Functions

private func formattedTime(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, secs)
}

private func shortFormattedTime(seconds: Int) -> String {
    let minutes = seconds / 60
    let secs = seconds % 60
    return String(format: "%02d:%02d", minutes, secs)
}

// MARK: - App Intents

struct TogglePauseIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Pause"
    static var description = IntentDescription("Met en pause ou reprend le chronomètre")
    
    func perform() async throws -> some IntentResult {
        // Les App Intents s'exécutent dans l'extension widget, pas l'app principale
        // On utilise UserDefaults pour communiquer l'action
        let defaults = UserDefaults.standard
        let isPaused = defaults.bool(forKey: "ActivityTimer.isPaused")
        
        if isPaused {
            // Reprendre
            if let pauseDate = defaults.object(forKey: "ActivityTimer.pauseDate") as? Date,
               let startDate = defaults.object(forKey: "ActivityTimer.startDate") as? Date {
                let pauseDuration = Date().timeIntervalSince(pauseDate)
                let newStartDate = startDate.addingTimeInterval(pauseDuration)
                defaults.set(newStartDate, forKey: "ActivityTimer.startDate")
                defaults.set(false, forKey: "ActivityTimer.isPaused")
                defaults.removeObject(forKey: "ActivityTimer.pauseDate")
                
                // Mettre à jour la Live Activity
                await updateAllLiveActivities(isPaused: false, startDate: newStartDate)
            }
        } else {
            // Pause
            if let startDate = defaults.object(forKey: "ActivityTimer.startDate") as? Date {
                let elapsed = Int(Date().timeIntervalSince(startDate))
                defaults.set(true, forKey: "ActivityTimer.isPaused")
                defaults.set(elapsed, forKey: "ActivityTimer.pausedElapsedSeconds")
                defaults.set(Date(), forKey: "ActivityTimer.pauseDate")
                
                // Mettre à jour la Live Activity
                await updateAllLiveActivities(isPaused: true, startDate: startDate, pausedSeconds: elapsed)
            }
        }
        
        return .result()
    }
    
    private func updateAllLiveActivities(isPaused: Bool, startDate: Date, pausedSeconds: Int = 0) async {
        for activity in ActivityKit.Activity<ActivityTimerAttributes>.activities {
            let contentState = ActivityTimerAttributes.ContentState(
                startDate: startDate,
                isPaused: isPaused,
                pausedElapsedSeconds: pausedSeconds
            )
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }
}

struct StopActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Activity"
    static var description = IntentDescription("Arrête l'activité en cours")
    
    func perform() async throws -> some IntentResult {
        // Nettoyer UserDefaults
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "ActivityTimer.startDate")
        defaults.removeObject(forKey: "ActivityTimer.serviceCode")
        defaults.removeObject(forKey: "ActivityTimer.serviceLabel")
        defaults.removeObject(forKey: "ActivityTimer.serviceIcon")
        defaults.set(false, forKey: "ActivityTimer.isPaused")
        defaults.set(0, forKey: "ActivityTimer.pausedElapsedSeconds")
        defaults.removeObject(forKey: "ActivityTimer.pauseDate")
        
        // Terminer toutes les Live Activities
        for activity in ActivityKit.Activity<ActivityTimerAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        
        return .result()
    }
}
