# Configuration Info.plist pour HomeCare

## URL Scheme pour OAuth Callback

Ajoutez cette configuration dans votre fichier `Info.plist` :

### Via l'éditeur de propriétés Xcode

1. Ouvrez votre projet dans Xcode
2. Sélectionnez la cible **HomeCare**
3. Allez dans l'onglet **Info**
4. Dans la section **URL Types**, cliquez sur **+** pour ajouter un nouveau type
5. Configurez :
   - **Identifier** : `com.itercraft.homecare`
   - **URL Schemes** : `itercraft.homecare`
   - **Role** : Editor

### Via le code source XML

Si vous éditez directement le fichier `Info.plist`, ajoutez :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Vos autres clés existantes -->
    
    <!-- URL Scheme pour OAuth Callback -->
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
    
    <!-- App Transport Security (Production) -->
    <!-- En production, utilisez HTTPS uniquement -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    
</dict>
</plist>
```

## Vérification

Pour vérifier que l'URL Scheme est bien configuré :

1. Lancez l'app dans le simulateur
2. Ouvrez Safari dans le simulateur
3. Tapez dans la barre d'adresse : `itercraft.homecare://test`
4. L'app devrait s'ouvrir (ou demander confirmation)

## Notes importantes

- Le scheme `itercraft.homecare` doit correspondre exactement à celui configuré dans Keycloak
- Le Bundle Identifier de votre app devrait être `com.itercraft.homecare` ou similaire
- En production, assurez-vous d'utiliser HTTPS uniquement pour toutes les communications
