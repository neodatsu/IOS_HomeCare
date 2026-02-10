# HomeCare

Application iOS/iPadOS de gestion d'activités de maintenance par IterCraft.

## Fonctionnalités

- Authentification OAuth2/Keycloak
- Gestion d'activités de maintenance
- Chronomètre avec start/pause/stop
- Récapitulatifs par période
- Architecture DDD
- Accessibilité RGAA
- Dark Mode

## Installation

1. Cloner le repo
2. Ouvrir `HomeCare.xcodeproj`
3. Build & Run

## Authentification

- Serveur: https://authent.itercraft.com/
- Realm: itercraft
- Client ID: iterapp

## API

- Base: https://api.itercraft.com
- GET /api/maintenance/activities
- GET /api/maintenance/totals
- POST /api/maintenance/activities/{code}/start
- POST /api/maintenance/activities/{code}/stop

## Auteur

Laurent FERRER - IterCraft

## Licence

MIT
