# Design Moderne 2026 - HomeCare 🎨✨

## Vision Design

**Charte graphique épurée, minimaliste et moderne** - Exit les gradients colorés, place à la simplicité élégante.

---

## Principes de Design 2026

### 1. **Minimalisme** 🤍
- Fond blanc/noir selon le mode
- Pas de dégradés flashy
- Espaces aérés
- Typographie légère

### 2. **Couleurs fonctionnelles** 🎯
- Vert = Actions positives (Start, Actif)
- Rouge = Actions négatives (Stop)
- Orange = Pause
- Bleu = Information, inactif
- **Couleurs UNIES** (pas de dégradés)

### 3. **Contrastes nets** ⚫⚪
- Icônes en couleur unie sur fond pâle
- Textes primaires en noir/blanc
- Bordures fines et discrètes

---

## ActivityDetailView - Écran Chronomètre

### ❌ AVANT (2024 - Dépassé)

```swift
// Fond bleu-rose moche
LinearGradient(colors: [
    Color.blue.opacity(0.2),
    Color.purple.opacity(0.1)
], ...)

// Icône avec gradient bleu-rose dégueulasse
.foregroundStyle(
    LinearGradient(colors: [.blue, .purple], ...)
)
.glassEffect(...)  // Surimpression

// Boutons avec .buttonStyle(.glass) + background
// = Surimpression blanche horrible
```

---

### ✅ APRÈS (2026 - Moderne)

#### **Fond minimaliste**
```swift
private var backgroundGradient: some View {
    Color(.systemBackground)  // Blanc ou noir selon le thème
        .ignoresSafeArea()
}
```

**Résultat** : Fond propre qui s'adapte au mode clair/sombre

---

#### **Icône de l'activité - Épurée**
```swift
private var activityIcon: some View {
    ZStack {
        Circle()
            .fill(activity.isActive ? Color.green.opacity(0.12) : Color.blue.opacity(0.12))
            .frame(width: 100, height: 100)
        
        Image(systemName: activity.icon)
            .font(.system(size: 50))
            .foregroundColor(activity.isActive ? .green : .blue)  // Couleur UNIE
    }
}
```

**Résultat** : Icône propre, lisible, verte si active, bleue sinon

---

#### **Titre simple**
```swift
private var activityTitle: some View {
    Text(activity.serviceLabel)
        .font(.system(size: 24, weight: .semibold, design: .rounded))
        .foregroundColor(.primary)  // Noir ou blanc
        .multilineTextAlignment(.center)
}
```

**Résultat** : Texte sobre et lisible

---

#### **Chronomètre minimaliste**
```swift
private var chronometer: some View {
    VStack(spacing: 16) {
        // Grand chronomètre léger
        Text(formattedTime)
            .font(.system(size: 64, weight: .light, design: .rounded))
            .foregroundColor(.primary)
            .monospacedDigit()
        
        // Indicateur d'état
        if currentActivity.isActive {
            HStack(spacing: 6) {
                Circle()
                    .fill(isPaused ? Color.orange : Color.green)
                    .frame(width: 8, height: 8)
                
                Text(isPaused ? "En pause" : "En cours")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isPaused ? .orange : .green)
            }
        }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 50)
    .background(
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(.secondarySystemBackground))  // Gris très pâle
    )
}
```

**Résultat** : Grand chronomètre sur fond gris pâle, aéré et moderne

---

#### **Boutons Start/Stop - Minimalistes**

##### **Bouton Start - Vert épuré**
```swift
Button {
    startActivity()
} label: {
    VStack(spacing: 10) {
        Image(systemName: "play.fill")
            .font(.title)
            .foregroundColor(.green)
        
        Text("Start")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.green)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.green.opacity(0.1))  // Fond vert très pâle
    )
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.green.opacity(0.4), lineWidth: 2)  // Bordure verte
    )
}
.buttonStyle(.plain)
```

**Résultat** : Bouton vert épuré avec icône + texte, bordure discrète

---

##### **Bouton Stop - Rouge épuré**
```swift
Button {
    stopActivity()
} label: {
    VStack(spacing: 10) {
        Image(systemName: "stop.fill")
            .font(.title)
            .foregroundColor(.red)
        
        Text("Stop")
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.red)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 24)
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.red.opacity(0.1))  // Fond rouge très pâle
    )
    .overlay(
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.red.opacity(0.4), lineWidth: 2)  // Bordure rouge
    )
}
.buttonStyle(.plain)
```

**Résultat** : Bouton rouge épuré, même style que Start

---

##### **Bouton Pause - Orange épuré**
```swift
if currentActivity.isActive {
    Button {
        togglePause()
    } label: {
        HStack(spacing: 12) {
            Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                .font(.title2)
            
            Text(isPaused ? "Reprendre" : "Pause")
                .font(.callout)
                .fontWeight(.semibold)
        }
        .foregroundColor(isPaused ? .green : .orange)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill((isPaused ? Color.green : Color.orange).opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke((isPaused ? Color.green : Color.orange).opacity(0.3), lineWidth: 2)
        )
    }
    .buttonStyle(.plain)
}
```

**Résultat** : Bouton orange/vert selon l'état, style cohérent

---

## ConsentView & HomeView - Design 2026

### Fond moderne
```swift
private var backgroundGradient: some View {
    ZStack {
        // Fond ultra pâle, presque blanc
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.98, green: 0.99, blue: 1.0),
                Color(red: 0.99, green: 0.98, blue: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Lumière subtile
        RadialGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(0.8),
                Color.clear
            ]),
            center: .top,
            startRadius: 100,
            endRadius: 500
        )
    }
    .ignoresSafeArea()
}
```

**Résultat** : Fond lumineux et aéré, pas de bleu/rose agressif

---

## DashboardView - Cartes modernes

### ActivityCard épurée
```swift
HStack(spacing: 16) {
    // Icône dans cercle pâle
    ZStack {
        Circle()
            .fill(activity.isActive ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
            .frame(width: 56, height: 56)
        
        Image(systemName: activity.icon)
            .font(.system(size: 28))
            .foregroundColor(activity.isActive ? .green : .blue)  // UNIE
    }
    
    // Infos
    VStack(alignment: .leading, spacing: 6) {
        Text(activity.serviceLabel)
            .font(.headline)
            .foregroundColor(.primary)
        
        Text(activity.formattedTime)
            .font(.caption)
            .foregroundColor(.secondary)
    }
    
    Spacer()
    
    Image(systemName: "chevron.right")
        .foregroundColor(.secondary)
}
.padding(16)
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)  // Ombre douce
)
```

**Résultat** : Carte propre avec ombre subtile, pas de glassEffect

---

## Palette de couleurs 2026

| Usage | Couleur | Code | Notes |
|-------|---------|------|-------|
| Fond principal | Blanc/Noir | `.systemBackground` | S'adapte au thème |
| Fond secondaire | Gris pâle | `.secondarySystemBackground` | Pour les cartes |
| Texte principal | Noir/Blanc | `.primary` | Contraste maximal |
| Texte secondaire | Gris | `.secondary` | Infos moins importantes |
| Action positive | Vert | `.green` | Start, actif |
| Action négative | Rouge | `.red` | Stop |
| Pause | Orange | `.orange` | Pause |
| Information | Bleu | `.blue` | Éléments inactifs |

---

## Règles de design

### ✅ À FAIRE
- Couleurs unies (`.foregroundColor(.blue)`)
- Fonds pâles (`.opacity(0.1)` à `.opacity(0.15)`)
- Bordures fines (lineWidth: 1 à 2)
- Ombres douces (`.opacity(0.06)`)
- Typographie légère (`.weight(.light)`, `.weight(.medium)`)
- Espaces généreux (padding: 16 à 24)

### ❌ À ÉVITER
- Gradients colorés (`.foregroundStyle(LinearGradient(...))`)
- `.glassEffect()` partout
- `.buttonStyle(.glass)` + `.background()`
- Couleurs saturées (`.opacity(0.5)` et plus)
- Ombres fortes
- Textes en bold partout

---

## Migration rapide

### Remplacer ceci :
```swift
.foregroundStyle(LinearGradient(colors: [.blue, .purple], ...))
```

### Par ceci :
```swift
.foregroundColor(.blue)  // Couleur UNIE
```

---

### Remplacer ceci :
```swift
.background(LinearGradient(...))
.glassEffect(.regular.tint(.blue), ...)
```

### Par ceci :
```swift
.background(
    RoundedRectangle(cornerRadius: 12)
        .fill(Color.blue.opacity(0.1))
)
.overlay(
    RoundedRectangle(cornerRadius: 12)
        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
)
```

---

### Remplacer ceci :
```swift
LinearGradient(
    colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)],
    ...
)
```

### Par ceci :
```swift
Color(.systemBackground)  // Tout simplement
```

---

## Fichiers à modifier

- [x] ConsentView.swift - ✅ Corrigé
- [x] HomeView.swift - ✅ Corrigé
- [x] DashboardView.swift - ✅ Corrigé
- [ ] ActivityDetailView.swift - ⚠️ À corriger avec le code ci-dessus

---

## Résultat final

### Avant (2024) 😬
- Fonds bleu-rose agressifs
- Gradients partout
- Surimpression .glassEffect
- Contrastes faibles
- Design chargé

### Après (2026) ✨
- Fonds blancs épurés
- Couleurs unies fonctionnelles
- Pas de surimpression
- Contrastes nets
- Design minimaliste

---

**Bienvenue en 2026 !** 🚀

*Guide créé le 10 février 2026 - HomeCare by IterCraft*
