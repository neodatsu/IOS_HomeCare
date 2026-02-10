# HomeCare - Documentation Projet

## Vue d'ensemble

HomeCare est une application iOS/iPadOS développée en SwiftUI.

**Date de création**: 10 février 2026  
**Créateur**: Laurent FERRER

## Architecture

### Plateforme
- **Framework UI**: SwiftUI
- **Langage**: Swift
- **Plateformes cibles**: iOS, iPadOS

### Approche architecturale
- **Domain-Driven Development (DDD)** - L'application suit les principes du DDD
  - Séparation claire entre Domain, Application, Infrastructure et Presentation
  - Modèles riches avec logique métier encapsulée
  - Utilisation d'entités, d'agrégats et de value objects
  - Services de domaine pour la logique métier complexe

### Structure du projet

#### Vues principales
- `ContentView.swift` - Vue principale de l'application

#### Organisation DDD (à implémenter)
```
HomeCare/
├── Domain/           # Logique métier pure
│   ├── Entities/
│   │   └── Activity.swift       # ✅ Entité activité
│   ├── ValueObjects/
│   ├── Aggregates/
│   └── Services/
├── Application/      # Cas d'usage
├── Infrastructure/   # Implémentation technique
│   └── ActivityService.swift    # ✅ Service API activités
└── Presentation/     # Vues SwiftUI
    ├── HomeView.swift            # ✅ Page d'accueil
    ├── DashboardView.swift       # ✅ Tableau de bord
    └── Components/
        └── ActivityCard          # ✅ Carte d'activité
```

## Conventions de code

### Swift
- Utiliser SwiftUI pour toutes les interfaces utilisateur
- Privilégier Swift Concurrency (async/await) pour les opérations asynchrones
- Suivre les conventions de nommage Swift standard
- Utiliser `let` par défaut, `var` seulement quand nécessaire
- Préférer les types valeurs (struct) aux types références (class) quand approprié
- Éviter force unwrapping (`!`) - utiliser optional binding ou guard
- Utiliser les property wrappers SwiftUI appropriés (@State, @Binding, @StateObject, @ObservedObject, @EnvironmentObject)

### Bonnes pratiques iOS/iPadOS

#### Architecture et organisation
- **Separation of Concerns** : Respecter MV pattern de SwiftUI avec DDD
- **Single Responsibility** : Chaque composant a une seule responsabilité
- **Views légères** : Extraire la logique complexe dans des ViewModels ou Services
- **Réutilisabilité** : Créer des composants SwiftUI réutilisables et modulaires
- **Préférences système** : Respecter les préférences utilisateur (apparence, taille de texte, etc.)

#### Gestion des données
- **SwiftData** : Utiliser SwiftData pour la persistance locale (moderne, natif)
- **Codable** : Pour la sérialisation/désérialisation JSON
- **@Observable** : Pour les modèles observables (iOS 17+)
- **Immutabilité** : Favoriser les données immuables quand possible

#### Performance
- **Lazy loading** : Utiliser LazyVStack/LazyHStack pour les listes longues
- **@MainActor** : Garantir les mises à jour UI sur le thread principal
- **Task cancellation** : Annuler les tâches async appropriées
- **Image optimization** : Utiliser des assets appropriés et Image resizing

#### Sécurité et confidentialité
- **Keychain** : Stocker les données sensibles dans le Keychain
- **App Transport Security** : Utiliser HTTPS pour toutes les communications réseau
- **Privacy Manifests** : Déclarer l'utilisation des APIs nécessitant justification
- **Minimal permissions** : Demander uniquement les permissions nécessaires
- **Info.plist descriptions** : Expliquer clairement pourquoi chaque permission est nécessaire

#### Interface utilisateur
- **Human Interface Guidelines** : Suivre les HIG d'Apple
- **Adaptabilité** : Support des différentes tailles d'écran (iPhone, iPad)
- **Orientation** : Gérer portrait et paysage appropriés
- **Dark Mode** : Support complet du mode sombre
- **Dynamic Type** : Support des tailles de texte dynamiques
- **Safe Areas** : Respecter les safe areas (notch, Dynamic Island, etc.)
- **Native controls** : Privilégier les composants natifs SwiftUI

#### Tests
- **Unit tests** : Tester la logique métier (Domain layer)
- **Swift Testing** : Utiliser le framework Swift Testing moderne (@Test, #expect)
- **UI tests** : Tester les parcours utilisateur critiques
- **Accessibility tests** : Valider l'accessibilité

#### Localisation
- **Strings localisés** : Toutes les chaînes visibles doivent être localisables
- **String catalogs** : Utiliser les String Catalogs (Xcode 15+)
- **RTL support** : Support des langues de droite à gauche

#### Gestion d'erreurs
- **Do-try-catch** : Gérer les erreurs de manière appropriée
- **Result type** : Utiliser Result<Success, Failure> quand approprié
- **User feedback** : Afficher des messages d'erreur compréhensibles
- **Logging** : Utiliser os.Logger pour les logs structurés

### Documentation obligatoire
- **Tout le code DOIT être documenté et commenté**
- Utiliser les commentaires de documentation Swift (///)
- Expliquer le "pourquoi" et non seulement le "quoi"
- Documenter les paramètres, valeurs de retour et erreurs possibles

Exemple de documentation attendue :
```swift
/// Décrit brièvement la fonction ou le type
///
/// Description détaillée si nécessaire, expliquant le contexte
/// et les décisions de conception.
///
/// - Parameters:
///   - parametre1: Description du paramètre
///   - parametre2: Description du paramètre
/// - Returns: Description de la valeur retournée
/// - Throws: Description des erreurs possibles
```

### Organisation
- Garder les vues SwiftUI modulaires et réutilisables
- Séparer la logique métier (Domain) des vues (Presentation)
- Respecter les principes DDD pour l'organisation du code

## Accessibilité

### RGAA (Référentiel Général d'Amélioration de l'Accessibilité)
L'application **DOIT respecter les normes RGAA** :

- **Labels accessibles** : Tous les éléments interactifs doivent avoir des labels appropriés
- **Navigation au clavier** : Support complet pour la navigation alternative
- **Contraste** : Respecter les ratios de contraste minimums
- **Tailles de texte** : Support du Dynamic Type
- **VoiceOver** : Toutes les fonctionnalités accessibles avec VoiceOver
- **Groupement sémantique** : Utiliser les traits et groupes d'accessibilité appropriés

Utiliser systématiquement :
```swift
.accessibilityLabel("Description claire")
.accessibilityHint("Action ou contexte")
.accessibilityAddTraits(.isButton) // ou autre trait approprié
```

## Notes pour l'assistant IA

### Préférences
- Utiliser SwiftUI comme framework principal
- Proposer des solutions natives Apple quand c'est possible
- Utiliser Swift Concurrency plutôt que Dispatch ou Combine quand approprié

### Exigences strictes
1. **Architecture DDD** - Toujours respecter la séparation des responsabilités
2. **Documentation** - Chaque classe, struct, fonction doit être documentée
3. **Accessibilité RGAA** - Tous les composants doivent être accessibles

### Contexte du projet
Ce projet est en phase initiale de développement. La structure actuelle est le template de base Xcode.

## Ressources et références

### Apple Documentation
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Accessibility on iOS](https://developer.apple.com/accessibility/ios/)

### RGAA
- [Référentiel RGAA](https://www.numerique.gouv.fr/publications/rgaa-accessibilite/)
- [WCAG 2.1](https://www.w3.org/WAI/WCAG21/quickref/) (base du RGAA)

## TODO
- [ ] Mettre en place l'architecture DDD (dossiers Domain, Application, Infrastructure, Presentation)
- [ ] Définir les entités et agrégats du domaine
- [ ] Créer les modèles de données
- [ ] Implémenter les fonctionnalités principales
- [ ] Configurer SwiftData pour la persistance
- [ ] Créer le Privacy Manifest
- [ ] Configurer String Catalogs pour la localisation
- [ ] Mettre en place les tests avec Swift Testing
- [ ] Auditer l'accessibilité selon RGAA
- [ ] Implémenter le support Dark Mode
- [ ] Tester sur iPhone et iPad

---
*Dernière mise à jour: 10 février 2026*
