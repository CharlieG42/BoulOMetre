# Boul'O'Mètre

> **Application Android pour mesurer les distances en pétanque**

Boul'O'Mètre est une application mobile conçue pour les joueurs de pétanque qui souhaitent mesurer précisément les distances entre le cochonnet et leurs boules, sans publicité intrusive.

## 🎯 Fonctionnalités

### Version 1 (Actuelle)
- ✅ Accès à la caméra pour capturer les boules et le cochonnet
- ✅ Détection visuelle des boules et du cochonnet
- ✅ Calcul et affichage des distances en centimètres
- ✅ Interface intuitive avec overlay de détection en temps réel

### Version 2 (À venir)
- 🔜 Création de 2 équipes de 1, 2 ou 3 joueurs
- 🔜 Gestion manuelle des points
- 🔜 Historique des parties

### Version 3 (À venir)
- 🔜 Reconnaissance automatique des boules de chaque équipe
- 🔜 Calcul automatique des points
- 🔜 Correction manuelle possible

## 📱 Installation

### Prérequis
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version >= 3.0.0)
- Android Studio ou Visual Studio Code
- Un appareil Android (API >= 21)

### Étapes

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/CharlieG42/BoulOMetre.git
   cd BoulOMetre
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer les permissions Android**
   Ajoutez les permissions suivantes dans `android/app/src/main/AndroidManifest.xml` :
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-feature android:name="android.hardware.camera" />
   ```

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📂 Structure du projet

```
lib/
├── app/                       # Configuration globale
│   ├── app.dart               # Widget racine + thème
│   └── routes.dart            # Gestion des routes
├── screens/                   # Écrans
│   ├── home_screen.dart       # Accueil
│   ├── camera_screen.dart     # Caméra + détection
│   └── results_screen.dart    # Affichage des résultats
├── widgets/                   # Composants réutilisables
│   ├── camera_overlay.dart    # Overlay de détection
│   ├── distance_card.dart     # Carte de distance
│   └── action_button.dart     # Boutons personnalisés
├── models/                    # Modèles de données
│   ├── ball.dart              # Modèle Boule/Cochonnet
│   └── measurement.dart       # Modèle Mesure
├── services/                  # Logique métier
│   ├── camera_service.dart    # Gestion de la caméra
│   └── image_processor.dart   # Traitement d'image
└── utils/                     # Utilitaires
    ├── constants.dart         # Constantes globales
    └── helpers.dart           # Fonctions utiles
```

## 📦 Dépendances

| Package | Version | Usage |
|---------|---------|-------|
| `camera` | ^0.10.5+7 | Accès à la caméra |
| `image` | ^4.1.3 | Traitement d'image |

## 🤝 Contribution

Les contributions sont les bienvenues !

## 📄 Licence

Ce projet est sous licence MIT.