# DOSCO — La Bataille des Étoiles 🌌

Jeu de stratégie abstrait sur grille stellaire — Godot 4.3 / Android

## Structure du projet

```
dosco/
├── .github/workflows/build-android.yml  ← CI/CD GitHub Actions
├── assets/audio/sfx/                    ← 10 sons WAV extraits du HTML
├── scenes/
│   ├── Main.tscn / Main.gd              ← Routeur principal
│   ├── game/GameBoard.tscn / .gd        ← Plateau de jeu complet
│   ├── screens/                         ← 13 écrans
│   └── effects/CaptureEffect.gd
├── src/
│   ├── core/                            ← Moteur de jeu pur
│   │   ├── Constants.gd                 ← Plateau, pièces, directions
│   │   ├── Rules.gd                     ← getMoves, checkEnd
│   │   ├── AI.gd                        ← minimax alpha-beta n1→n7
│   │   └── GameState.gd
│   ├── autoloads/                       ← Singletons Godot
│   │   ├── GameManager.gd
│   │   ├── AudioManager.gd
│   │   └── HapticManager.gd
│   ├── network/NetworkManager.gd        ← WebSocket Railway
│   ├── persistence/
│   │   ├── AuthDB.gd
│   │   └── SaveManager.gd
│   └── data/
│       ├── Galaxies.gd
│       └── I18n.gd                      ← 259 clés, 5 langues
└── project.godot
```

## Build via GitHub Actions (recommandé)

### 1. Pousser ce dossier sur GitHub

### 2. Le workflow `.github/workflows/build-android.yml` se déclenche automatiquement

### 3. Récupérer l'APK

Aller dans **Actions → dernier workflow → Artifacts → DOSCO-APK-xxx**

## Configuration requise pour build release signé

Ajouter ces **Secrets GitHub** (Settings → Secrets → Actions) :

| Secret | Valeur |
|--------|--------|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i release.keystore` |
| `KEYSTORE_ALIAS` | Alias de votre clé |
| `KEYSTORE_PASSWORD` | Mot de passe keystore |
| `KEY_PASSWORD` | Mot de passe clé |

## Serveur backend

- WebSocket : `wss://dosco-backend-production.up.railway.app`
- Protocole JSON défini dans `src/network/NetworkManager.gd`

## 5 langues

FR / EN / ES / AR / PT — `LangManager.t("Texte FR")`

## IA — 5 niveaux par galaxie

| Galaxie | IA | Profondeur |
|---------|-----|-----------|
| Voie Lactée | NÉBULEUSE | 2 + 15% aléa |
| Andromède | PULSARE | 3 + 10% aléa |
| Sombrero | QUASAR | 4 + 5% aléa |
| Tourbillon | SUPERNOVA | ID-6, 1.5s |
| Cigare | TROU NOIR | ID-7, 2.5s |
