//
//  CalendarView.swift
//  HomeCare
//
//  Created by Laurent FERRER on 11/02/2026.
//

import SwiftUI

/// Vue du calendrier mensuel des activités
///
/// Affiche un calendrier permettant de voir les jours où des activités
/// ont été effectuées et lesquelles.
struct CalendarView: View {
    
    // MARK: - Properties
    
    /// Service d'authentification pour accéder aux infos utilisateur
    @Bindable var authService: AuthenticationService
    
    /// Service de gestion des activités
    @State private var activityService: ActivityService
    
    /// Mois actuellement affiché
    @State private var currentMonth: Date = Date()
    
    /// Jour sélectionné (pour voir les détails)
    @State private var selectedDay: Date?
    
    /// Indique si la feuille de détails est affichée
    @State private var showDayDetails = false
    
    /// Calendrier pour les calculs de dates
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    
    /// Initialise la vue du calendrier avec les services nécessaires
    ///
    /// - Parameter authService: Service d'authentification
    init(authService: AuthenticationService) {
        self.authService = authService
        self._activityService = State(initialValue: ActivityService(authService: authService))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // En-tête avec navigation mois
                monthNavigationHeader
                
                // Grille du calendrier
                ScrollView {
                    VStack(spacing: 24) {
                        calendarGrid
                        
                        // Légende
                        legendSection
                    }
                    .padding()
                }
            }
            .background(backgroundGradient)
            .navigationTitle("Calendrier")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showDayDetails) {
                if let selectedDay = selectedDay {
                    DayDetailsSheet(date: selectedDay, activityService: activityService)
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    // MARK: - Components
    
    /// Dégradé de fond
    private var backgroundGradient: some View {
        ZStack {
            // Couche de base
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.15),
                    Color.cyan.opacity(0.08)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Couche de lumière
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ]),
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
    
    /// En-tête de navigation entre les mois
    private var monthNavigationHeader: some View {
        HStack {
            // Bouton mois précédent
            Button {
                withAnimation {
                    changeMonth(by: -1)
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Mois précédent")
            
            Spacer()
            
            // Mois et année actuel
            VStack(spacing: 4) {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Button {
                    withAnimation {
                        currentMonth = Date()
                    }
                } label: {
                    Text("Aujourd'hui")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .accessibilityLabel("Revenir au mois actuel")
            }
            
            Spacer()
            
            // Bouton mois suivant
            Button {
                withAnimation {
                    changeMonth(by: 1)
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Mois suivant")
        }
        .padding()
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    /// Grille du calendrier
    private var calendarGrid: some View {
        VStack(spacing: 12) {
            // Jours de la semaine (L M M J V S D)
            weekdayHeaders
            
            // Grille des jours du mois
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                            isToday: calendar.isDateInToday(date),
                            hasActivity: hasActivityOn(date: date)
                        )
                        .onTapGesture {
                            selectedDay = date
                            showDayDetails = true
                        }
                    } else {
                        // Cellule vide pour les jours hors du mois
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    /// En-têtes des jours de la semaine
    private var weekdayHeaders: some View {
        HStack(spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 8)
    }
    
    /// Section de légende
    private var legendSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Légende")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                LegendItem(color: .blue, text: "Jour sélectionné")
                LegendItem(color: .green, text: "Activité effectuée")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Computed Properties
    
    /// Chaîne du mois et de l'année
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    /// Symboles des jours de la semaine (L, M, M, J, V, S, D)
    private var weekdaySymbols: [String] {
        var symbols = calendar.veryShortWeekdaySymbols
        // Réorganiser pour commencer par lundi
        let sunday = symbols.removeFirst()
        symbols.append(sunday)
        return symbols.map { $0.uppercased() }
    }
    
    /// Jours du mois à afficher dans la grille
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        // Générer 6 semaines (42 jours) pour avoir une grille complète
        for _ in 0..<42 {
            // Ajuster pour que la semaine commence le lundi
            let adjustedDate = calendar.date(byAdding: .day, value: 1, to: date)!
            
            if calendar.isDate(adjustedDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(adjustedDate)
            } else {
                days.append(nil) // Jour hors du mois actuel
            }
            
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return days
    }
    
    // MARK: - Methods
    
    /// Change le mois affiché
    ///
    /// - Parameter offset: Nombre de mois à ajouter (positif) ou retirer (négatif)
    private func changeMonth(by offset: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    /// Vérifie si une activité a été effectuée à une date donnée
    ///
    /// - Parameter date: Date à vérifier
    /// - Returns: `true` si au moins une activité a été effectuée ce jour
    private func hasActivityOn(date: Date) -> Bool {
        // TODO: Implémenter avec les vraies données de l'API
        // Pour l'instant, simulation avec des données aléatoires
        let dayOfMonth = calendar.component(.day, from: date)
        // Simuler des activités les jours pairs et les weekends
        return dayOfMonth % 2 == 0 || calendar.isDateInWeekend(date)
    }
    
    /// Charge les données
    private func loadData() async {
        // TODO: Charger l'historique des activités depuis l'API
        // Pour l'instant, on charge juste les activités actuelles
        do {
            try await activityService.loadAll()
        } catch {
            // Gérer l'erreur silencieusement pour l'instant
            print("Erreur lors du chargement: \(error.localizedDescription)")
        }
    }
}

// MARK: - Day Cell Component

/// Cellule représentant un jour dans le calendrier
private struct DayCell: View {
    
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasActivity: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)
            
            // Indicateur d'activité
            if hasActivity {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isToday ? Color.blue : Color.clear, lineWidth: 2)
        )
        .opacity(isCurrentMonth ? 1.0 : 0.3)
        .accessibilityLabel(accessibilityText)
    }
    
    private var textColor: Color {
        if isToday {
            return .blue
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if hasActivity && isCurrentMonth {
            return Color.green.opacity(0.15)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
    
    private var accessibilityText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .long
        
        var text = formatter.string(from: date)
        if isToday {
            text += ", aujourd'hui"
        }
        if hasActivity {
            text += ", activité effectuée"
        }
        return text
    }
}

// MARK: - Legend Item Component

/// Élément de la légende
private struct LegendItem: View {
    
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Day Details Sheet

/// Feuille affichant les détails d'un jour sélectionné
private struct DayDetailsSheet: View {
    
    let date: Date
    let activityService: ActivityService
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date sélectionnée
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text(formattedDate)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    // Liste des activités (simulée)
                    VStack(spacing: 16) {
                        Text("Activités de la journée")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // TODO: Afficher les vraies activités depuis l'API
                        ActivityDayRow(
                            icon: "leaf.fill",
                            label: "Passer la tondeuse",
                            duration: "45min",
                            color: .green
                        )
                        
                        ActivityDayRow(
                            icon: "drop.fill",
                            label: "Passer le Karcher",
                            duration: "30min",
                            color: .blue
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Détails du jour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateStyle = .full
        return formatter.string(from: date).capitalized
    }
}

// MARK: - Activity Day Row Component

/// Ligne d'activité pour un jour
private struct ActivityDayRow: View {
    
    let icon: String
    let label: String
    let duration: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.headline)
                
                Text(duration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    CalendarView(authService: AuthenticationService())
}
