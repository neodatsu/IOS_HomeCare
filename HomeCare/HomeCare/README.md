# HomeCare 🏠💚

Application iOS native de gestion des temps d'activités de maintenance, développée par **IterCraft**.

## 📱 À propos

HomeCare est une application iOS moderne qui permet de suivre et chronométrer vos activités de maintenance quotidiennes. L'application se connecte à votre système Keycloak pour l'authentification et synchronise vos données en temps réel avec le backend.

## ✨ Fonctionnalités

### 🔐 Authentification & Sécurité
- **Connexion OAuth2** via Keycloak
- **Consentement RGPD** conforme au premier lancement
- **Gestion sécurisée** des tokens d'authentification

### ⏱️ Chronomètre d'activités
- **Démarrage/Arrêt** d'activités via API
- **Pause locale** sans synchronisation serveur
- **Affichage en temps réel** du temps écoulé (HH:MM:SS)
- **Synchronisation automatique** avec le backend

### 📊 Suivi des temps
- **Vue d'ensemble** de toutes vos activités
- **Statistiques détaillées** par période :
  - Aujourd'hui
  - Cette semaine
  - Ce mois
  - Cette année
- **Totaux par activité** avec détail des périodes

### ♿ Accessibilité & Design
- **Conformité RGAA** avec labels VoiceOver
- **Support Dynamic Type** pour l'accessibilité
- **Mode sombre** natif iOS
- **Design moderne 2026** minimaliste et épuré

## 🎨 Design System

### Charte graphique moderne
L'application adopte un design **minimaliste et épuré** inspiré des tendances 2026 :

#### Palette de couleurs
- 🟢 **Vert** : Actions positives (Start, Actif)
- 🔴 **Rouge** : Actions négatives (Stop)
- 🟠 **Orange** : État de pause
- 🔵 **Bleu** : Information, éléments inactifs

#### Principes de design
- **Fond blanc/noir** selon le thème système
- **Couleurs unies** (pas de gradients colorés)
- **Typographie légère** et aérée
- **Espaces généreux** entre les éléments
- **Contrastes nets** pour la lisibilité

#### Composants modernes
- Cartes avec ombres douces
- Bordures fines et discrètes
- Icônes en couleur unie dans cercles pâles
- Boutons avec fond coloré très pâle + bordure

## 🏗️ Architecture

### Technologies utilisées
- **SwiftUI** - Interface utilisateur déclarative
- **Swift Concurrency** - async/await pour les opérations asynchrones
- **Observation Framework** - Gestion d'état moderne avec `@Observable`
- **OAuth2/Keycloak** - Authentification sécurisée

### Structure du projet

```
HomeCare/
├── Models/
│   ├── Activity.swift              # Modèle d'activité
│   ├── ActivityTotals.swift        # Totaux par période
│   └── UserInfo.swift              # Informations utilisateur
├── Services/
│   ├── AuthenticationService.swift # Authentification OAuth2
│   ├── ActivityService.swift       # Gestion des activités
│   └── ConsentManager.swift        # Gestion du consentement RGPD
├── Views/
│   ├── ContentView.swift           # Navigation principale
│   ├── HomeView.swift              # Page d'accueil
│   ├── ConsentView.swift           # Écran de consentement RGPD
│   ├── DashboardView.swift         # Tableau de bord des activités
│   ├── ActivityDetailView.swift    # Chronomètre d'activité
│   └── PrivacyPolicyView.swift     # Politique de confidentialité
└── Guides/
    ├── DESIGN_2026_GUIDE.md        # Guide du design moderne
    ├── CLEAN_BUTTONS_GUIDE.md      # Bonnes pratiques boutons
    └── DESIGN_IMPROVEMENTS.md      # Améliorations apportées
```

## 🚀 Installation

### Prérequis
- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**
- Serveur Keycloak configuré
- Backend API HomeCare

### Configuration

1. **Cloner le repository**
```bash
git clone https://github.com/votre-org/homecare-ios.git
cd homecare-ios
```

2. **Configurer l'authentification**

Modifiez les constantes dans `AuthenticationService.swift` :
```swift
private let keycloakURL = "https://votre-keycloak.com"
private let realm = "votre-realm"
private let clientId = "homecare-mobile"
```

3. **Configurer l'API**

Modifiez l'URL de base dans `ActivityService.swift` :
```swift
private let baseURL = "https://votre-api.com"
```

4. **Compiler et lancer**
```bash
open HomeCare.xcodeproj
# Puis Command+R dans Xcode
```

## 🔒 Confidentialité & RGPD

### Données collectées
- **Nom & Email** : Via authentification Keycloak
- **Temps d'activités** : Enregistrés localement et synchronisés avec le backend

### Sécurité
- **Chiffrement HTTPS** pour toutes les communications
- **OAuth2** pour l'authentification
- **Tokens sécurisés** stockés dans UserDefaults
- **Pas de partage de données** avec des tiers

### Droits des utilisateurs
Les utilisateurs peuvent :
- ✅ Accéder à leurs données
- ✅ Rectifier leurs données
- ✅ Supprimer leurs données
- ✅ Exporter leurs données
- ✅ S'opposer au traitement

Contact : **contact@itercraft.com**

## 📖 Documentation

### Guides de design
- **[Design 2026 Guide](DESIGN_2026_GUIDE.md)** - Guide complet du design moderne
- **[Clean Buttons Guide](CLEAN_BUTTONS_GUIDE.md)** - Éviter les erreurs de design
- **[Design Improvements](DESIGN_IMPROVEMENTS.md)** - Améliorations apportées

### Exemples de code

#### Démarrer une activité
```swift
Task {
    try await activityService.startActivity(serviceCode: "KARCHER")
}
```

#### Arrêter une activité
```swift
Task {
    try await activityService.stopActivity(serviceCode: "KARCHER")
}
```

#### Charger les statistiques
```swift
Task {
    try await activityService.loadAll()
    // activityService.totals contient les statistiques
}
```

## 🧪 Tests

L'application utilise **Swift Testing** avec macros :

```swift
import Testing

@Suite("Activity Tests")
struct ActivityTests {
    @Test("Format du temps")
    func testTimeFormatting() {
        let activity = Activity(...)
        #expect(activity.formattedTime == "01:30:00")
    }
}
```

## 🎯 Roadmap

### Version 1.1 (À venir)
- [ ] Notifications push pour rappels
- [ ] Widgets iOS pour vue rapide
- [ ] Export PDF des statistiques
- [ ] Mode hors ligne avec synchronisation

### Version 1.2 (Futur)
- [ ] Apple Watch app
- [ ] Siri Shortcuts
- [ ] Graphiques de tendances
- [ ] Objectifs et badges

## 🤝 Contribution

Les contributions sont les bienvenues ! Veuillez :

1. **Fork** le projet
2. **Créer une branche** (`git checkout -b feature/AmazingFeature`)
3. **Commit** vos changements (`git commit -m 'Add AmazingFeature'`)
4. **Push** vers la branche (`git push origin feature/AmazingFeature`)
5. **Ouvrir une Pull Request**

### Normes de code
- Respecter le **Swift Style Guide** d'Apple
- Ajouter des **commentaires de documentation**
- Suivre l'**architecture existante**
- Tester sur **iOS clair ET sombre**

## 📄 Licence

Ce projet est sous licence **MIT** - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Auteurs

**IterCraft Team**
- Laurent FERRER - *Développement initial* - [IterCraft](https://itercraft.com)

## 🙏 Remerciements

- Apple pour SwiftUI et les frameworks iOS
- Keycloak pour l'authentification OAuth2
- La communauté Swift pour les outils et ressources

## 📞 Support

Pour toute question ou problème :
- 📧 Email : **contact@itercraft.com**
- 🐛 Issues : [GitHub Issues](https://github.com/votre-org/homecare-ios/issues)
- 📱 Version actuelle : **1.0.0**

---

**Fait avec ❤️ par IterCraft** - *Février 2026*

🏠 HomeCare - Simplifiez votre gestion de maintenance
