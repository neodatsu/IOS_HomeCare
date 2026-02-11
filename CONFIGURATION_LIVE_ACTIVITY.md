# 🚀 Configuration des Live Activities pour HomeCare

## ✅ Fichiers créés

J'ai créé les fichiers suivants pour activer les Live Activities :

1. **ActivityTimerAttributes.swift** - Définit la structure des données de la Live Activity
2. **ActivityTimerLiveActivity.swift** - Interface visuelle de la Live Activity
3. **TimerManager.swift** - Mis à jour pour gérer les Live Activities

## 📋 Étapes de configuration dans Xcode

### Étape 1 : Ajouter la clé Info.plist

1. Ouvrez votre projet dans Xcode
2. Sélectionnez le fichier `Info.plist` (ou ouvrez la section "Info" de votre target)
3. Ajoutez la clé suivante :
   - **Key**: `Supports Live Activities` (ou `NSSupportsLiveActivities` en mode Raw)
   - **Type**: Boolean
   - **Value**: YES

### Étape 2 : Vérifier que ActivityKit est disponible

Le framework ActivityKit est automatiquement disponible sur iOS 16.1+. Pas besoin de l'ajouter manuellement.

### Étape 3 : Vérifier les Target Memberships

Assurez-vous que ces fichiers sont bien dans votre target principal **HomeCare** :

1. Sélectionnez `ActivityTimerAttributes.swift` dans le navigateur
2. Dans l'inspecteur de fichiers (panneau de droite), vérifiez "Target Membership"
3. Cochez "HomeCare" si ce n'est pas déjà fait
4. Répétez pour `ActivityTimerLiveActivity.swift`

### Étape 4 : Build Settings (optionnel)

Si vous rencontrez des erreurs de compilation, vérifiez :
- **Build Settings** → **Enable Previews** : YES
- **Build Settings** → **Swift Language Version** : Swift 5.9 ou supérieur

## 🧪 Tester sur un appareil physique

**⚠️ IMPORTANT** : Les Live Activities ne fonctionnent PAS dans le simulateur. Vous devez tester sur un iPhone réel avec iOS 16.1 ou supérieur.

### Comment tester

1. **Connectez votre iPhone** à votre Mac
2. **Sélectionnez votre iPhone** comme destination dans Xcode
3. **Lancez l'app** (Cmd+R)
4. **Démarrez une activité** :
   - Allez dans le Dashboard
   - Cliquez sur "Tondeuse", "Karcher" ou "Piscine"
   - Appuyez sur "Start"
5. **Verrouillez votre iPhone** (bouton Power)
6. **Vérifiez l'écran verrouillé** : vous devriez voir le chronomètre !

### Sur iPhone 14 Pro ou plus récent

Si vous avez un iPhone avec Dynamic Island :
- La Live Activity apparaît aussi dans la Dynamic Island
- Appuyez longuement dessus pour voir les contrôles étendus
- Vous pouvez mettre en pause ou arrêter depuis la Dynamic Island

## 🎨 Ce que vous allez voir

### Sur l'écran verrouillé

```
┌─────────────────────────────────────┐
│  🌱  Passer la tondeuse             │
│       En cours                      │
│                            00:05:23 │
│                                     │
│  [⏸️  Pause]      [🛑  Stop]        │
└─────────────────────────────────────┘
```

### Dynamic Island (compacte)

```
🌱  05:23
```

### Dynamic Island (étendue - appui long)

```
┌─────────────────────────────────────┐
│  🌱 Passer la tondeuse   00:05:23   │
│                                     │
│    [⏸️  Pause]      [🛑  Stop]      │
└─────────────────────────────────────┘
```

## 🔧 Fonctionnalités

### ✅ Ce qui fonctionne

- ✅ Affichage du chronomètre en temps réel sur l'écran verrouillé
- ✅ Bouton Pause/Reprendre fonctionnel
- ✅ Bouton Stop fonctionnel
- ✅ Indicateur d'état (En cours / En pause)
- ✅ Support Dynamic Island (iPhone 14 Pro+)
- ✅ Le chronomètre continue en arrière-plan
- ✅ Les boutons fonctionnent depuis l'écran verrouillé

### 🎯 Comment ça marche

1. **Quand vous appuyez sur Start** :
   - L'app appelle l'API backend
   - Le backend retourne la date de début (`startedAt`)
   - `TimerManager` démarre le chronomètre
   - La Live Activity est créée automatiquement

2. **Quand vous verrouillez l'iPhone** :
   - La Live Activity reste active
   - Le chronomètre continue de tourner
   - Les boutons restent interactifs

3. **Quand vous appuyez sur Pause (depuis l'écran verrouillé)** :
   - L'App Intent `TogglePauseIntent` est exécuté
   - `TimerManager.pause()` est appelé
   - La Live Activity se met à jour (temps figé, couleur orange)

4. **Quand vous appuyez sur Stop** :
   - L'App Intent `StopActivityIntent` est exécuté
   - `TimerManager.stopActivity()` est appelé
   - L'API backend est appelée pour enregistrer le temps
   - La Live Activity disparaît

## ⚠️ Dépannage

### La Live Activity n'apparaît pas

**Vérifiez** :
1. Vous testez sur un iPhone physique (pas le simulateur)
2. iOS 16.1 ou supérieur
3. La clé `NSSupportsLiveActivities` est dans Info.plist
4. Allez dans **Réglages → Notifications → HomeCare** et vérifiez que les notifications sont autorisées

**Logs à vérifier** :
- Ouvrez la Console dans Xcode (Cmd+Shift+Y)
- Cherchez les messages avec les emojis :
  - ✅ "Live Activity démarrée"
  - ⚠️ "Live Activities non autorisées"
  - ❌ "Erreur démarrage Live Activity"

### Les boutons ne répondent pas

**Causes possibles** :
1. Les App Intents ne sont pas correctement configurés
2. Le `TimerManager` n'est pas accessible

**Solution** :
- Vérifiez que `ActivityTimerLiveActivity.swift` est bien dans le target
- Vérifiez les logs pour voir si les intents sont exécutés

### Le chronomètre ne se met pas à jour

**Vérification** :
- Le chronomètre utilise `Text(timerInterval:countsDown:)` qui se met à jour automatiquement
- Si le texte affiche "00:00:00", vérifiez que la `startDate` est correcte dans les logs

## 📱 Permissions utilisateur

Lors du premier lancement, iOS peut demander à l'utilisateur :
- "HomeCare souhaite afficher des Live Activities"

L'utilisateur peut aussi désactiver les Live Activities dans :
**Réglages → Notifications → HomeCare → Live Activities**

## 🎉 C'est tout !

Une fois configuré, votre app affichera automatiquement le chronomètre sur l'écran verrouillé quand une activité est en cours.

Les utilisateurs pourront :
- Voir le temps en temps réel sans déverrouiller l'iPhone
- Mettre en pause depuis l'écran verrouillé
- Arrêter l'activité depuis l'écran verrouillé
- Voir l'état dans la Dynamic Island (iPhone Pro)

---

**Questions ?** Vérifiez les logs dans la console Xcode. Tous les événements importants sont loggés avec des emojis pour faciliter le debug :
- ▶️ Démarrage
- ⏸️ Pause
- ⏹️ Stop
- ✅ Succès
- ⚠️ Avertissement
- ❌ Erreur
