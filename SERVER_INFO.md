# Serveur Multijoueur DOSCO

Le mode en ligne utilise un serveur WebSocket hébergé sur Railway.

## URL du serveur
wss://dosco-backend-production.up.railway.app

## Flux d'authentification
1. Requête HTTP POST vers /api/guest ou /api/login
2. Récupération d'un token JWT
3. Connexion WebSocket avec le token en query param

## Messages principaux
- find_match
- move
- game_end
- rematch_request
- etc.

Le code client est dans `src/network/NetworkManager.gd`.
