# Configuration Keycloak pour HomeCare

## Informations du serveur

- **URL Keycloak**: https://authent.itercraft.com/
- **Realm**: itercraft
- **Client ID**: iterapp

## Configuration du client dans Keycloak

### 1. Créer ou configurer le client `iterapp`

Connectez-vous à la console d'administration Keycloak et accédez au realm `itercraft`.

#### Paramètres généraux (General Settings)

| Paramètre | Valeur |
|-----------|---------|
| **Client ID** | `iterapp` |
| **Name** | HomeCare iOS App |
| **Description** | Application mobile HomeCare pour iOS/iPadOS |
| **Client Protocol** | `openid-connect` |
| **Access Type** | `public` |

#### Paramètres d'authentification (Authentication Settings)

| Paramètre | Valeur |
|-----------|---------|
| **Standard Flow Enabled** | ✅ ON |
| **Direct Access Grants Enabled** | ❌ OFF (non recommandé pour mobile) |
| **Implicit Flow Enabled** | ❌ OFF |
| **Service Accounts Enabled** | ❌ OFF |
| **Authorization Enabled** | ❌ OFF |

#### URLs de redirection (Valid Redirect URIs)

Ajoutez les URIs suivantes dans la liste des redirections valides :

```
itercraft.homecare://*
itercraft.homecare://oauth-callback
```

**Important** : Le wildcard `*` permet de gérer différents chemins de callback.

#### URLs de post-logout (Valid Post Logout Redirect URIs)

```
itercraft.homecare://*
```

#### Web Origins

Pour éviter les problèmes CORS (si nécessaire) :

```
itercraft.homecare://*
+
```

Le `+` permet tous les domaines des Valid Redirect URIs.

### 2. Paramètres avancés (Advanced Settings)

| Paramètre | Valeur | Description |
|-----------|--------|-------------|
| **Proof Key for Code Exchange Code Challenge Method** | `S256` | ✅ **OBLIGATOIRE** pour PKCE |
| **Access Token Lifespan** | `300` secondes (5 min) | Durée de vie du token |
| **Client Session Idle** | `1800` secondes (30 min) | Temps d'inactivité max |
| **Client Session Max** | `36000` secondes (10h) | Durée max de session |

### 3. Scopes autorisés

Vérifiez que ces scopes sont disponibles pour le client :

- ✅ `openid` (obligatoire pour OpenID Connect)
- ✅ `profile` (pour les infos de profil)
- ✅ `email` (pour l'adresse email)

### 4. Mappers (optionnel mais recommandé)

Ajoutez des mappers pour inclure des informations utilisateur dans les tokens :

#### Mapper "email"
- **Name**: email
- **Mapper Type**: User Property
- **Property**: email
- **Token Claim Name**: email
- **Claim JSON Type**: String
- **Add to ID token**: ON
- **Add to access token**: ON
- **Add to userinfo**: ON

#### Mapper "full name"
- **Name**: full name
- **Mapper Type**: User's full name
- **Token Claim Name**: name
- **Add to ID token**: ON
- **Add to access token**: ON
- **Add to userinfo**: ON

#### Mapper "username"
- **Name**: username
- **Mapper Type**: User Property
- **Property**: username
- **Token Claim Name**: preferred_username
- **Claim JSON Type**: String
- **Add to ID token**: ON
- **Add to access token**: ON
- **Add to userinfo**: ON

## Configuration iOS

### Info.plist

Ajoutez cette configuration dans votre `Info.plist` pour gérer les URL schemes :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.itercraft.homecare</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>itercraft.homecare</string>
        </array>
    </dict>
</array>
```

### App Transport Security (ATS)

Si votre serveur Keycloak n'a pas de certificat SSL valide (développement uniquement), ajoutez :

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>authent.itercraft.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

**⚠️ ATTENTION** : En production, utilisez TOUJOURS HTTPS avec un certificat valide et supprimez cette exception !

## Vérification de la configuration

### Tester les endpoints

Vous pouvez tester que les endpoints sont accessibles :

#### 1. Well-known configuration
```bash
curl https://authent.itercraft.com/realms/itercraft/.well-known/openid-configuration
```

Cette commande doit retourner un JSON avec tous les endpoints disponibles.

#### 2. Vérifier l'endpoint d'autorisation

Ouvrez dans un navigateur :
```
https://authent.itercraft.com/realms/itercraft/protocol/openid-connect/auth?client_id=iterapp&redirect_uri=itercraft.homecare://oauth-callback&response_type=code&scope=openid%20profile%20email
```

Vous devriez voir la page de connexion Keycloak.

## Résumé des paramètres clés

| Paramètre | Valeur |
|-----------|---------|
| Client ID | `iterapp` |
| Client Type | Public |
| Standard Flow | ✅ Enabled |
| Direct Access | ❌ Disabled |
| PKCE | ✅ S256 Required |
| Redirect URI | `itercraft.homecare://oauth-callback` |
| Valid Redirect URIs | `itercraft.homecare://*` |
| Post Logout URI | `itercraft.homecare://*` |

## Sécurité

### ✅ Points de sécurité respectés

- **PKCE (Proof Key for Code Exchange)** : Protection contre les attaques d'interception de code
- **Public Client** : Pas de client secret (impossible à sécuriser dans une app mobile)
- **URL Scheme personnalisé** : Évite les conflits avec d'autres apps
- **Tokens courts** : Durée de vie limitée des access tokens
- **HTTPS obligatoire** : Toutes les communications chiffrées

### ⚠️ Recommandations supplémentaires

1. **Refresh tokens** : Configurez une rotation des refresh tokens
2. **Token binding** : Si supporté, activez le token binding
3. **Rate limiting** : Configurez des limites de tentatives de connexion
4. **2FA** : Activez l'authentification à deux facteurs dans Keycloak
5. **Session management** : Surveillez les sessions actives

## Support et dépannage

### Problèmes courants

#### "Invalid redirect_uri"
- Vérifiez que `itercraft.homecare://oauth-callback` est dans les Valid Redirect URIs
- Vérifiez que l'URL Scheme est configuré dans Info.plist

#### "Invalid client"
- Vérifiez que le client `iterapp` existe dans le realm `itercraft`
- Vérifiez que le client est activé (Enabled = ON)

#### "Invalid PKCE"
- Vérifiez que PKCE S256 est activé dans les paramètres avancés
- Vérifiez que le code_challenge est bien envoyé

#### L'app ne s'ouvre pas après connexion
- Vérifiez la configuration de l'URL Scheme dans Info.plist
- Vérifiez que le Bundle Identifier correspond
- Relancez l'app et le simulateur

---
*Document créé le 10 février 2026*
