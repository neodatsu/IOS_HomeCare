# ⚡ Guide rapide : Activer les Live Activities

## 🎯 Étape UNIQUE à faire

### Dans Xcode :

1. **Cliquez** sur votre projet "HomeCare" dans le navigateur (panneau de gauche)

2. **Sélectionnez** le target "HomeCare" (sous TARGETS)

3. **Allez** dans l'onglet "Info"

4. **Cliquez** sur le bouton "+" (en bas de la liste)

5. **Tapez** : `Supports Live Activities`
   (Xcode devrait l'auto-compléter)

6. **Vérifiez** que le type est "Boolean"

7. **Cochez** la case (ou mettez "YES")

C'est tout ! 🎉

## 🧪 Tester maintenant

1. **Connectez** votre iPhone à votre Mac
2. **Sélectionnez-le** comme destination dans Xcode
3. **Build** (Cmd+R)
4. **Démarrez** une activité (Tondeuse, Karcher, etc.)
5. **Ouvrez** la Console Xcode (Cmd+Shift+Y)
6. **Cherchez** : `✅ Live Activity démarrée`
7. **Verrouillez** votre iPhone
8. **Admirez** votre Live Activity ! 🎉

## 📱 Ce que vous devriez voir

Sur l'écran verrouillé de votre iPhone :

```
╔═══════════════════════════════════════╗
║  🌱  Passer la tondeuse               ║
║       En cours                        ║
║                            00:00:12   ║
║                                       ║
║  [⏸️  Pause]      [🛑  Stop]          ║
╚═══════════════════════════════════════╝
```

Le chronomètre se met à jour automatiquement toutes les secondes.

## 🆘 Si ça ne marche pas

Regardez la Console Xcode :

### Si vous voyez :
```
⚠️ Live Activities non autorisées
📱 areActivitiesEnabled: false
```

**→ Solution :** Vous avez oublié la clé Info.plist OU les notifications sont désactivées

**Vérifiez :**
1. Info.plist contient `NSSupportsLiveActivities = YES`
2. Sur l'iPhone : Réglages → Notifications → HomeCare → activé

### Si vous voyez :
```
❌ Erreur démarrage Live Activity: [message]
```

**→ Envoyez-moi le message d'erreur complet**, je vous aiderai.

### Si vous ne voyez rien dans les logs :

**→ Vérifiez :**
1. Vous testez sur un **iPhone physique** (pas simulateur)
2. L'app est bien en cours d'exécution
3. Vous avez bien cliqué sur "Start" dans l'app

## ✅ C'est prêt !

Tout le code est déjà en place. Il ne manque que la clé Info.plist.

**Fichiers mis à jour :**
- ✅ TimerManager.swift
- ✅ ActivityTimerLiveActivity.swift (avec ActivityTimerAttributes)
- ✅ ActivityDetailView.swift

**Il ne vous reste qu'à :**
1. Ajouter la clé Info.plist (2 minutes)
2. Tester sur votre iPhone (1 minute)
3. Profiter ! 🎉
