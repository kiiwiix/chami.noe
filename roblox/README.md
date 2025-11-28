# Hello Kitty Cozy Farm Roblox Scripts

This folder contient tous les scripts utilisés pour le prototype "Hello Kitty Cozy Farm". Les fichiers sont organisés pour correspondre aux services Roblox (ServerScriptService, StarterPlayer, etc.).

## Structure

```
roblox/
├── ReplicatedStorage/
│   └── FarmManager.lua
├── ServerScriptService/
│   ├── CreateHelloKittyWorld.server.lua
│   └── FarmServer.lua
├── StarterGui/
│   └── HUD.client.lua
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── FarmClient.client.lua
```

## Fonctionnalités principales

- **FarmManager** : module serveur qui crée les parcelles et gère la croissance multi-étapes (Seed → Sprout → Bloom). Récompense les joueurs lors de la récolte et expose les coûts/gains.
- **FarmServer** : script serveur qui instancie les fermes, maintient les coins du joueur et autorise les plantages/récoltes via des RemoteEvents.
- **FarmClient** : script client qui relie les clics, affiche les stades de croissance et souligne les plantes prêtes à récolter.
- **HUD.client** : mini interface kawaii indiquant coins, level et un rappel pour récolter les fleurs.
- **CreateHelloKittyWorld** : génère le décor pastel (arbres, nuages flottants, particules, décorations Hello Kitty, coin pique-nique et parterres de fleurs scintillants avec une lumière douce et non éblouissante).

## Mise en place

1. Copiez chaque script dans le service correspondant de votre expérience Roblox Studio.
2. Assurez-vous que `PlantEvent` et `HarvestEvent` sont présents dans `ReplicatedStorage` (le script serveur les crée automatiquement s’ils n’existent pas).
3. Lancez le jeu : chaque joueur reçoit une petite ferme 3x3, peut planter des graines, attendre la floraison puis récolter pour gagner des SanrioCoins.

Les attributs sur chaque parcelle (`Planted`, `StageName`, `ReadyToHarvest`) sont répliqués côté client pour mettre à jour l’interface et les effets.
