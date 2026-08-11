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
│   │   ├── settings.kv      # Écran réglages (KV language)
│   │   └── settings.py      # Logique de l'écran réglages
│   ├── widgets/
│   │   ├── custom_widgets.py # Widgets personnalisés
│   │   └── custom_widgets.kv # Déclarations KV des widgets
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

### Écran Réglages
- Réglage de la sensibilité de l'horizontalité

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

## 🤖 Construction Automatique avec GitHub Actions

### Workflow de Build

Un workflow GitHub Actions est configuré pour **construire automatiquement l'APK** à chaque push sur la branche `py-kivy-version` ou `main` (quand des fichiers dans `py_boulometre/` sont modifiés).

**Fichier du workflow** : `.github/workflows/python_build_apk.yml`

### Déclenchement

Le workflow se déclenche automatiquement dans les cas suivants :
- ✅ **Push** sur les branches `py-kivy-version` ou `main`
- ✅ **Pull Request** vers les branches `py-kivy-version` ou `main`
- ✅ **Modifications** dans le dossier `py_boulometre/`

### Processus de Build

1. **Checkout** du dépôt
2. **Setup Python 3.10**
3. **Installation** de Buildozer et des dépendances
4. **Configuration** de l'environnement Android (SDK, NDK)
5. **Acceptation** des licences Android
6. **Build** de l'APK avec Buildozer
7. **Renommage** de l'APK avec le préfixe `PyBoulOMetre`
8. **Upload** de l'APK comme artifact

### Récupération de l'APK

Après chaque build réussi :
1. Allez dans l'onglet **Actions** de votre dépôt GitHub
2. Sélectionnez le workflow **PyBoulOMetre Build APK**
3. Cliquez sur le run le plus récent
4. Dans la section **Artifacts**, téléchargez **PyBoulOMetre-APK**

Le fichier APK portera le nom : `PyBoulOMetre-{NUMERO}-debug.apk`

### Commande manuelle pour tester localement

Si vous voulez tester le build localement avant de pousser :

```bash
cd py_boulometre
pip install buildozer
buildozer init
buildozer -v android debug
```

L'APK sera généré dans `py_boulometre/bin/` avec un nom comme `pyboulometre-0.1-debug.apk`.

## 📝 Configuration Buildozer

Le fichier `buildozer.spec` est pré-configuré avec :
- **Package name** : `pyboulometre`
- **Package domain** : `com.charlieg42`
- **Title** : `PyBoul'O'Mètre`
- **Android API** : 33 (minimum: 21)
- **Architecture** : arm64-v8a
- **Bootstrap** : sdl2

Vous pouvez modifier ces paramètres selon vos besoins.

## ⚠️ Problèmes courants et solutions

### 1. Erreur de caméra sur mobile
**Problème** : La caméra ne s'initialise pas sur Android.
**Solution** : Vérifiez que les permissions sont correctement configurées dans `buildozer.spec` :
```ini
android.permissions = CAMERA, VIBRATE
android.api = 33
android.minapi = 21
```

### 2. Buildozer échoue avec Android NDK
**Problème** : Erreur de compilation liée au NDK.
**Solution** : Assurez-vous d'utiliser la bonne version du NDK (23b) :
```ini
android.ndk = 23b
```

### 3. Dépendances manquantes
**Problème** : Erreur d'importation de modules.
**Solution** : Vérifiez que toutes les dépendances sont dans `requirements.txt` et installez-les :
```bash
pip install -r requirements.txt
```

### 4. Problème de texture OpenCV
**Problème** : Erreur de conversion d'image.
**Solution** : Assurez-vous que OpenCV est installé :
```bash
pip install opencv-python
```

## 🔄 Comparaison avec la version Flutter

| Aspect | Flutter | Python/Kivy |
|--------|---------|--------------|
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Taille APK** | ~10-15 Mo | ~20-30 Mo |
| **Développement** | Dart | Python |
| **UI Déclarative** | ✅ Widgets | ✅ KV Language |
| **Accès Caméra** | ✅ Plugin camera | ✅ OpenCV |
| **Build Android** | ✅ Flutter build | ✅ Buildozer |
| **Hot Reload** | ✅ | ❌ |
| **Communauté** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

## 🤝 Contribution

Les contributions sont les bienvenues ! Ouvrez une Pull Request pour proposer vos améliorations.

## 📜 Licence

Ce projet est sous licence MIT, comme la version Flutter.
