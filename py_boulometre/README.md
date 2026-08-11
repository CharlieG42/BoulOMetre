# PyBoul'O'Mètre

> **Application Android en Python/Kivy pour mesurer les distances en pétanque**

PyBoul'O'Mètre est la version Python/Kivy de l'application Boul'O'Mètre, conçue pour les joueurs de pétanque qui souhaitent mesurer précisément les distances entre le cochonnet et leurs boules.

## 🎯 Fonctionnalités

- ✅ Accès à la caméra pour capturer les boules et le cochonnet
- ✅ Détection visuelle des boules et du cochonnet (positionnement manuel)
- ✅ Calcul et affichage des distances en centimètres
- ✅ Interface intuitive avec overlay de détection en temps réel
- ✅ Niveau à bulle pour vérifier l'horizontalité du téléphone
- ✅ Sélection manuelle des boules
- ✅ Affichage des résultats avec classement

## 📱 Prérequis

- Python 3.8+
- Kivy 2.1.0+
- Buildozer (pour la compilation Android)
- OpenCV (optionnel, pour le traitement d'image avancé)

## 🚀 Installation

### Pour développement local

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/CharlieG42/BoulOMetre.git
   cd BoulOMetre/py_boulometre
   ```

2. **Créer un environnement virtuel**
   ```bash
   python -m venv venv
   source venv/bin/activate  # Linux/Mac
   # ou
   venv\Scripts\activate  # Windows
   ```

3. **Installer les dépendances**
   ```bash
   pip install -r requirements.txt
   ```

4. **Lancer l'application**
   ```bash
   python src/main.py
   ```

### Pour Android (via Buildozer)

1. Installer Buildozer
   ```bash
   pip install buildozer
   ```

2. Initialiser Buildozer
   ```bash
   buildozer init
   ```

3. Modifier le fichier `buildozer.spec` selon vos besoins

4. Builder l'APK
   ```bash
   buildozer -v android debug
   ```

## 📁 Structure du projet

```
py_boulometre/
├── src/
│   ├── main.py              # Point d'entrée principal
│   ├── app.py               # Configuration de l'application Kivy
│   ├── screens/
│   │   ├── home.kv          # Écran d'accueil (KV language)
│   │   ├── home.py          # Logique de l'écran d'accueil
│   │   ├── camera.kv        # Écran caméra (KV language)
│   │   ├── camera.py        # Logique de l'écran caméra
│   │   ├── results.kv       # Écran résultats (KV language)
│   │   └── results.py       # Logique de l'écran résultats
│   ├── widgets/
│   │   └── custom_widgets.py # Widgets personnalisés
│   ├── models/
│   │   └── ball.py          # Modèle Ball
│   ├── services/
│   │   ├── camera_service.py # Service caméra
│   │   └── image_processor.py # Traitement d'image
│   └── utils/
│       ├── constants.py     # Constantes globales
│       └── helpers.py       # Fonctions utilitaires
├── assets/
│   └── icons/               # Icônes de l'application
├── requirements.txt         # Dépendances Python
├── buildozer.spec           # Configuration Buildozer
└── README.md
```

## 🎨 Interface Utilisateur

L'application utilise le langage KV de Kivy pour définir les interfaces utilisateur de manière déclarative, similaire à Flutter.

### Écran d'accueil
- Bouton "Lancer la mesure" pour accéder à la caméra
- Bouton "Réglages" pour configurer l'application
- Bouton "Historique" (à venir)

### Écran Caméra
- Prévisualisation de la caméra
- Niveau à bulle pour vérifier l'horizontalité
- Bouton de capture
- Overlay de mesure avec guides concentriques
- Sélection manuelle du cochonnet et des boules

### Écran Résultats
- Liste des boules classées par distance
- Distance par rapport au cochonnet
- Identification de la boule la plus proche

## 📊 Modèles de données

### Ball
- `id`: Identifiant unique
- `x`: Position X en pixels
- `y`: Position Y en pixels
- `radius`: Rayon en pixels
- `distance_to_piglet`: Distance par rapport au cochonnet en cm
- `is_piglet`: Booléen indiquant si c'est le cochonnet

## 🔧 Services

### CameraService
- Initialisation de la caméra
- Capture d'images
- Gestion du flash
- Changement de caméra

### ImageProcessor
- Détection des boules (simplifiée)
- Calcul des distances
- Conversion pixels/cm

## 🎛️ Utilitaires

### Constants
- Couleurs de l'application
- Tailles et espacements
- Diamètres réels des boules et cochonnet

### Helpers
- Formatage des distances
- Calculs géométriques
- Génération d'IDs

## 🤝 Contribution

Les contributions sont les bienvenues ! Ouvrez une Pull Request pour proposer vos améliorations.

## 📜 Licence

Ce projet est sous licence MIT, comme la version Flutter.
