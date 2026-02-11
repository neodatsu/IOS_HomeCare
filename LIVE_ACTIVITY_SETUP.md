# Configuration de la Live Activity pour HomeCare

Ce guide explique comment configurer la Live Activity pour afficher le chronomètre sur l'écran verrouillé.

## ✅ Fichiers créés

Les fichiers suivants ont été créés et sont prêts à être utilisés :

1. **ActivityTimerManager.swift** - Gestionnaire centralisé du chronomètre
2. **ActivityTimerAttributes.swift** - Définition des attributs de la Live Activity
3. **ActivityTimerLiveActivity.swift** - Interface de la Live Activity
4. **ActivityDetailView.swift** - Mis à jour pour utiliser le nouveau système

## 📋 Étapes de configuration dans Xcode

### Étape 1 : Ajouter le framework ActivityKit

1. Ouvrez votre projet dans Xcode
2. Sélectionnez votre cible principale (HomeCare)
3. Allez dans l'onglet "Frameworks, Libraries, and Embedded Content"
4. Cliquez sur le `+` et ajoutez `ActivityKit.framework`

### Étape 2 : Activer les Live Activities dans Info.plist

1. Ouvrez le fichier `Info.plist` de votre app
2. Ajoutez la clé suivante :

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

Ou via l'interface visuelle d'Xcode :
- Cliquez sur le `+` dans Info.plist
- Ajoutez "Supports Live Activities" (Boolean) = YES

### Étape 3 : Ajouter les fichiers au bon target

Assurez-vous que les fichiers suivants sont bien dans votre target principal :

- ✅ ActivityTimerManager.swift
- ✅ ActivityTimerAttributes.swift
- ✅ ActivityTimerLiveActivity.swift

Pour vérifier :
1. Sélectionnez chaque fichier dans le navigateur de projet
2. Dans l'inspecteur de fichiers (à droite), vérifiez que "Target Membership" inclut "HomeCare"

### Étape 4 : Configurer les App Intents

Les boutons de la Live Activity utilisent des App Intents. Assurez-vous que :

1. Le framework `AppIntents` est importé
2. Les structures `TogglePauseIntent` et `StopActivityIntent` sont accessibles

### Étape 5 : Tester sur un appareil physique

**Important** : Les Live Activities ne fonctionnent PAS dans le simulateur iOS. Vous devez tester sur un iPhone physique (iOS 16.1+).

Pour tester :

1. Branchez votre iPhone
2. Sélectionnez-le comme destination de build
3. Lancez l'app (Cmd+R)
4. Démarrez une activité (tondeuse, karcher, etc.)
5. Verrouillez votre iPhone
6. Vous devriez voir le chronomètre sur l'écran verrouillé !

## 🎯 Fonctionnalités implémentées

### Écran verrouillé (Lock Screen)
- ✅ Affichage du chronomètre en temps réel
- ✅ Nom et icône de l'activité
- ✅ Bouton Pause/Reprendre
- ✅ Bouton Stop
- ✅ Indicateur d'état (En cours / En pause)

### Dynamic Island (iPhone 14 Pro et plus)
- ✅ Vue compacte avec icône et temps
- ✅ Vue étendue avec contrôles
- ✅ Boutons interactifs Pause et Stop
- ✅ Animation fluide

### Persistance
- ✅ Le chronomètre continue en arrière-plan
- ✅ État sauvegardé dans UserDefaults
- ✅ Restauration automatique au redémarrage de l'app
- ✅ Live Activity maintenue même après redémarrage

## 🔧 Dépannage

### La Live Activity n'apparaît pas

1. **Vérifiez Info.plist** : `NSSupportsLiveActivities` doit être `true`
2. **Vérifiez le device** : Testez sur un iPhone physique (iOS 16.1+)
3. **Vérifiez les permissions** : Allez dans Réglages > Notifications > HomeCare
4. **Vérifiez les logs** : Ouvrez la console Xcode pour voir les messages du logger

### Les boutons ne fonctionnent pas

1. Vérifiez que les App Intents sont correctement importés
2. Assurez-vous que `ActivityTimerManager.shared` est accessible
3. Vérifiez les logs pour les erreurs

### Le chronomètre s'arrête en arrière-plan

Cela ne devrait **plus** arriver ! Le nouveau système utilise :
- Calcul basé sur `Date()` plutôt qu'un timer incrémental
- Sauvegarde persistante dans UserDefaults
- Restauration automatique de l'état

## 📱 Apparence de la Live Activity

### Sur l'écran verrouillé

```
┌─────────────────────────────────────┐
│  🌱  Passer la tondeuse             │
│       En cours                      │
│                            01:23:45 │
│                                     │
│  ⏸️  Pause        🛑  Stop          │
└─────────────────────────────────────┘
```

### Sur la Dynamic Island (étendue)

```
┌─────────────────────────────────────┐
│  🌱 Passer la tondeuse   01:23:45   │
│                                     │
│    ⏸️  Pause        🛑  Stop        │
└─────────────────────────────────────┘
```

### Dynamic Island (compacte)

```
🌱  01:23
```

## 🎨 Personnalisation

Vous pouvez personnaliser :

### Couleurs
Dans `ActivityTimerLiveActivity.swift`, modifiez :
- `.tint(.green)` pour le bouton Reprendre
- `.tint(.orange)` pour le bouton Pause
- `.tint(.red)` pour le bouton Stop

### Icônes
Dans `ActivityTimerManager.swift`, méthode `iconForServiceCode()`, ajoutez vos propres icônes

### Textes
Modifiez les textes dans `ActivityTimerLiveActivity.swift`

## 📚 Références

- [ActivityKit Documentation](https://developer.apple.com/documentation/activitykit)
- [Live Activities Guide](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [App Intents](https://developer.apple.com/documentation/appintents)

## 🚀 Prochaines étapes

Une fois la Live Activity testée et validée, vous pourriez ajouter :

1. **Notifications push** pour mettre à jour la Live Activity à distance
2. **Graphiques** affichant la progression de l'activité
3. **Statistiques** directement dans la Live Activity
4. **Support Apple Watch** pour contrôler depuis la montre

---

**Note** : Si vous rencontrez des problèmes, vérifiez d'abord les logs dans la console Xcode. Le `ActivityTimerManager` log tous les événements importants avec des emojis pour faciliter le debug :
- ▶️ Démarrage
- ⏸️ Pause
- ⏹️ Stop
- ✅ Succès
- ❌ Erreur
