# GitHub Actions pour HomeCare iOS 🚀

## Vue d'ensemble

Ce projet utilise plusieurs workflows GitHub Actions pour automatiser les processus de CI/CD, tests et qualité de code.

> **Note** : Les workflows de déploiement TestFlight/App Store ne sont pas inclus car ils nécessitent un compte Apple Developer.

## 📋 Workflows disponibles

### 1. **iOS CI/CD** (`ios-ci.yml`)

**Déclencheurs** : Push sur `main`/`develop` et Pull Requests

**Jobs** :
- ✅ **Build & Test** - Compilation et tests sur iPhone 17 Pro (iOS 26.0)
- 🔍 **SwiftLint** - Analyse statique du code
- 🔐 **Security Scan** - Scan de vulnérabilités avec Trivy
- 📊 **Code Coverage** - Génération et upload vers Codecov
- ♿ **Accessibility Audit** - Tests d'accessibilité

**Configuration** :
- **Xcode** : Version 26.2 (17C52)
- **macOS Runner** : macos-15
- **iOS Simulateur** : 26.0
- **Device** : iPhone 17 Pro

**Durée estimée** : ~15-20 minutes

---

### 2. **PR Checks** (`pr-checks.yml`)

**Déclencheurs** : Pull Requests vers `main`/`develop`

**Jobs** :
- ✅ **PR Checks** - Vérification du titre, TODOs, taille des fichiers
- 📊 **Code Quality** - SwiftLint strict, print statements, force unwraps
- 🏗️ **Build Check** - Vérification que le code compile
- ♿ **Accessibility Check** - Vérification des labels/hints/traits
- 🔐 **Security Check** - Détection de secrets hardcodés
- 🏷️ **Auto Label** - Ajout automatique de labels

**Durée estimée** : ~10 minutes

---

### 3. **Nightly Build** (`nightly-build.yml`)

**Déclencheurs** : 
- Cron : Tous les jours à 2h UTC
- Manuel via `workflow_dispatch`

**Jobs** :
- 🌙 Build complet sur iPhone 17 Pro
- 🧪 Tous les tests
- ⚡ Tests de performance
- 🔍 Détection de fuites mémoire
- 💬 Notification en cas d'échec

**Durée estimée** : ~20-30 minutes

---

## 🔧 Configuration requise

### Secrets GitHub (optionnels)

Allez dans **Settings → Secrets and variables → Actions** et ajoutez :

#### Pour les notifications (optionnel) :
```
SLACK_WEBHOOK_URL              # URL du webhook Slack
```

#### Généré automatiquement :
```
GITHUB_TOKEN                   # Généré automatiquement par GitHub
```

> **Note** : Aucun secret lié à Apple Developer n'est nécessaire car nous n'avons pas de compte développeur.

---

## 📦 Dépendances

### Homebrew (macOS runners)
- `swiftlint` - Analyse de code Swift

### GitHub Actions
- `actions/checkout@v4` - Checkout du code
- `actions/upload-artifact@v4` - Upload d'artifacts
- `codecov/codecov-action@v4` - Upload de coverage
- `aquasecurity/trivy-action` - Scan de sécurité
- `amannn/action-semantic-pull-request@v5` - Vérification PR
- `actions/labeler@v5` - Labels automatiques

---

## 🎯 Utilisation

### Lancer les tests en local

Avant de push, testez localement avec Xcode 26.2 :

```bash
# SwiftLint
swiftlint lint

# Build
xcodebuild build \
  -project HomeCare.xcodeproj \
  -scheme HomeCare \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0'

# Tests
xcodebuild test \
  -project HomeCare.xcodeproj \
  -scheme HomeCare \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.0'
```

### Lancer le nightly build manuellement

1. Allez dans **Actions** → **Nightly Build**
2. Cliquez sur **Run workflow**
3. Sélectionnez la branche
4. Cliquez sur **Run workflow**

---

## 🔍 Vérifications automatiques

### SwiftLint Rules

Configurées dans `.swiftlint.yml` :
- ❌ Pas de `print()` en production
- ⚠️ Limite de 120 caractères par ligne
- ⚠️ Limite de 50 lignes par fonction
- ⚠️ Max 5 paramètres par fonction
- ⚠️ Complexité cyclomatique < 10

### Security Checks

- 🔐 Détection de mots de passe hardcodés
- 🔑 Détection de clés API hardcodées
- 🎟️ Détection de tokens hardcodés
- ⚠️ Warning sur UserDefaults pour données sensibles

### Accessibility Checks

- ♿ Vérification de `accessibilityLabel`
- 💬 Vérification de `accessibilityHint`
- 🏷️ Vérification de `accessibilityAddTraits`

---

## 📊 Badges de statut

Ajoutez ces badges à votre README :

```markdown
![iOS CI](https://github.com/votre-org/homecare-ios/workflows/iOS%20CI%2FCD/badge.svg)
![SwiftLint](https://github.com/votre-org/homecare-ios/workflows/iOS%20CI%2FCD/badge.svg)
![Coverage](https://codecov.io/gh/votre-org/homecare-ios/branch/main/graph/badge.svg)
```

---

## 🐛 Troubleshooting

### Erreur : "Xcode version not found"

Vérifiez que la version de Xcode 26.2 est bien installée :
```yaml
DEVELOPER_DIR: /Applications/Xcode_26.2.app/Contents/Developer
```

### Erreur : "Simulator not found"

Le simulateur iPhone 17 Pro avec iOS 26.0 doit être installé :
```bash
xcrun simctl list devices
```

### Erreur : "SwiftLint not found"

Le workflow installe SwiftLint automatiquement :
```yaml
- name: Install SwiftLint
  run: brew install swiftlint
```

### Timeout sur les tests

Augmentez le timeout si nécessaire :
```yaml
timeout-minutes: 30
```

---

## 📈 Optimisations

### Cache des dépendances

Pour accélérer les builds, ajoutez le cache :

```yaml
- name: Cache DerivedData
  uses: actions/cache@v4
  with:
    path: ~/Library/Developer/Xcode/DerivedData
    key: ${{ runner.os }}-derived-data-${{ hashFiles('**/*.swift') }}
```

### Parallel testing

Pour des tests plus rapides :

```yaml
-parallel-testing-enabled YES
-maximum-parallel-testing-workers 4
```

---

## 🔄 Workflow de contribution

1. **Créer une branche** : `git checkout -b feature/ma-feature`
2. **Commit** : `git commit -m "feat: ajouter nouvelle feature"`
3. **Push** : `git push origin feature/ma-feature`
4. **Créer une PR** → Les checks automatiques se lancent
5. **Review** et merge quand tous les checks sont ✅

---

## 📝 Conventions de commit

Pour que les PRs soient automatiquement validées :

```
feat: nouvelle fonctionnalité
fix: correction de bug
docs: mise à jour documentation
style: formatage code
refactor: refactorisation
test: ajout de tests
chore: tâches de maintenance
```

---

## 💻 Environnement de développement

### Configuration locale

- **Xcode** : 26.2 (17C52) - Février 2026
- **iOS** : 26.0
- **Swift** : 6.2
- **Device testé** : iPhone 17 Pro

### Sans compte Apple Developer

Ce projet est configuré pour fonctionner **sans compte Apple Developer** :
- ✅ Tests sur simulateurs
- ✅ Build en mode Debug
- ✅ Code coverage et analyses
- ❌ Pas de déploiement TestFlight
- ❌ Pas de distribution App Store

Pour activer ces fonctionnalités plus tard, vous devrez :
1. Créer un compte Apple Developer (99€/an)
2. Configurer les certificats et profils de provisioning
3. Ajouter les workflows de déploiement

---

## 🎯 Roadmap Actions

### Disponible maintenant
- [x] Build & Test automatiques
- [x] SwiftLint et qualité de code
- [x] Scan de sécurité
- [x] Code coverage
- [x] Tests d'accessibilité
- [x] Nightly builds

### Nécessite un compte Apple Developer
- [ ] Déploiement TestFlight
- [ ] Distribution App Store
- [ ] Beta testing externe
- [ ] App Store Connect API

### Améliorations futures (sans compte)
- [ ] Analyse de performance automatique
- [ ] Screenshots automatiques des simulateurs
- [ ] Tests UI automatisés
- [ ] Génération de changelog automatique
- [ ] Intégration avec Fastlane (mode simulateur)

---

## 📞 Support

En cas de problème avec les workflows :

1. Vérifiez les **logs dans Actions**
2. Consultez la **documentation GitHub Actions**
3. Ouvrez une **issue** avec le label `🔧 CI/CD`

---

**Maintenu par IterCraft** - Février 2026

**Versions** :
- Xcode 26.2 (17C52)
- iOS 26.0
- iPhone 17 Pro
- macOS Sequoia (runners macos-15)

