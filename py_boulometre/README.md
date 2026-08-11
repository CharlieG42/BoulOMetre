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

### Pour développement local (PC)

#### Sur Linux (Ubuntu/Debian)
```bash
# Dépendances système
sudo apt-get update
sudo apt-get install -y git python3 python3-pip python3-venv \
    openjdk-17-jdk-headless autoconf libtool pkg-config \
    zlib1g-dev cmake libffi-dev libssl-dev

# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances Python
pip install -r requirements.txt
```

#### Sur macOS
```bash
# Installer les dépendances avec Homebrew
brew install python@3.10 openjdk@17 autoconf libtool pkg-config cmake

# Créer un environnement virtuel
python3 -m venv venv
source venv/bin/activate

# Installer les dépendances Python
pip install -r requirements.txt
```

#### Sur Windows
```bash
# Installer Python 3.10+ depuis python.org
# Installer Java JDK 17 depuis adoptium.net

# Créer un environnement virtuel
python -m venv venv
venv\Scripts\activate

# Installer les dépendances Python
pip install -r requirements.txt
```

### Pour Android (via Buildozer)

#### Installation de Buildozer
```bash
pip install buildozer
```

#### Installation des outils Android
- **Android SDK** : Télécharger depuis [Android Studio](https://developer.android.com/studio) ou utiliser `sdkmanager`
- **Android NDK** : Version **25.2.9519653** (recommandée)
- **Java JDK** : Version **17** (OpenJDK Temurin recommandé)

#### Configuration des variables d'environnement
```bash
# Linux/macOS
export ANDROID_HOME=/chemin/vers/android-sdk
export ANDROID_NDK_HOME=/chemin/vers/android-ndk
export JAVA_HOME=/chemin/vers/jdk-17
export PATH=$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_NDK_HOME:$JAVA_HOME/bin:$PATH

# Windows
set ANDROID_HOME=C:\chemin\vers\android-sdk
set ANDROID_NDK_HOME=C:\chemin\vers\android-ndk
set JAVA_HOME=C:\chemin\vers\jdk-17
set PATH=%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%ANDROID_NDK_HOME%;%JAVA_HOME%\bin;%PATH%
```

#### Accepter les licences Android
```bash
yes | sdkmanager --licenses
```

#### Installer les packages Android nécessaires
```bash
sdkmanager "platforms;android-33"
sdkmanager "build-tools;33.0.0"
sdkmanager "platform-tools"
sdkmanager "cmdline-tools;latest"
```

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

1. **Configurer l'environnement** (voir section Prérequis)

2. **Configurer buildozer.spec**
   - Vérifier que `android.sdk_path` et `android.ndk_path` pointent vers les bons chemins
   - Vérifier que `android.api = 33` et `android.ndk = 25.2.9519653`

3. **Builder l'APK**
   ```bash
   cd py_boulometre
   buildozer android clean
   buildozer -v android debug
   ```

4. **Trouver l'APK**
   L'APK sera généré dans `bin/` avec un nom comme `pyboulometre-0.1.0-debug.apk`

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
│   │   ├── results.py       # Logique de l'écran résultats
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
└── README.md               # Documentation complète
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

Un workflow GitHub Actions est configuré pour **construire automatiquement l'APK** à chaque push sur la branche `py-kivy-version` ou `main`.

**Fichier du workflow** : `.github/workflows/py_boulometre_build_apk.yml`

### Déclenchement

Le workflow se déclenche automatiquement dans les cas suivants :
- ✅ **Push** sur les branches `py-kivy-version` ou `main`
- ✅ **Pull Request** vers les branches `py-kivy-version` ou `main`

### Processus de Build

1. **Checkout** du dépôt
2. **Setup Python 3.10**
3. **Installation** des dépendances système (OpenJDK, etc.)
4. **Installation** de Buildozer
5. **Installation Android SDK/NDK** (version 25.2.9519653)
6. **Acceptation** de toutes les licences Android
7. **Installation** des packages Android nécessaires (platforms, build-tools, etc.)
8. **Configuration** de buildozer.spec avec les chemins existants
9. **Build** de l'APK avec Buildozer
10. **Upload** de l'APK comme artifact

### Récupération de l'APK

Après chaque build réussi :
1. Allez dans l'onglet **Actions** de votre dépôt GitHub
2. Sélectionnez le workflow **PyBoulOMetre Build APK**
3. Cliquez sur le run le plus récent
4. Dans la section **Artifacts**, téléchargez **PyBoulOMetre-APK**

Le fichier APK portera le nom : `PyBoulOMetre-{NUMERO}-debug.apk`

### Configuration Buildozer

Le fichier `buildozer.spec` est pré-configuré avec :
- **Package name** : `pyboulometre`
- **Package domain** : `com.charlieg42`
- **Title** : `PyBoul'O'Mètre`
- **Android API** : 33 (minimum: 21)
- **NDK version** : 25.2.9519653
- **Architecture** : arm64-v8a
- **Bootstrap** : sdl2

### Commandes utiles pour Buildozer

```bash
# Initialiser Buildozer (si buildozer.spec n'existe pas)
buildozer init

# Builder l'APK (debug)
buildozer android debug

# Builder l'APK (release)
buildozer android release

# Nettoyer avant un nouveau build
buildozer android clean

# Voir la version de Buildozer
buildozer --version

# Voir les informations de configuration
buildozer android debug -v
```

## ⚠️ Problèmes courants et solutions

### 1. Erreur : Aidl not found
**Problème** : L'outil Aidl (Android Interface Definition Language) n'est pas trouvé.
**Solution** : 
- Installer les Build-Tools : `sdkmanager "build-tools;33.0.0"`
- Ajouter au PATH : `export PATH=$ANDROID_HOME/build-tools/33.0.0:$PATH`

### 2. Erreur : No Java compiler found
**Problème** : Java n'est pas installé ou non détecté.
**Solution** : 
- Installer OpenJDK 17 : `sudo apt-get install openjdk-17-jdk-headless`
- Configurer JAVA_HOME : `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`

### 3. Erreur : Android NDK not found
**Problème** : Le NDK n'est pas installé ou non détecté.
**Solution** : 
- Installer le NDK 25.2.9519653 via Android Studio ou sdkmanager
- Configurer ANDROID_NDK_HOME : `export ANDROID_NDK_HOME=/chemin/vers/ndk`

### 4. Erreur : License not accepted
**Problème** : Les licences Android ne sont pas acceptées.
**Solution** : `yes | sdkmanager --licenses`

### 5. Erreur : Recipe not found for...
**Problème** : Une dépendance Python est manquante.
**Solution** : 
- Vérifier que toutes les dépendances sont dans `requirements.txt`
- Installer la dépendance manquante : `pip install <package>`

### 6. Erreur : Buildozer failed to execute command
**Problème** : Problème de mémoire ou de configuration.
**Solution** : 
- Augmenter la mémoire disponible (Buildozer a besoin de 4GB+)
- Vérifier que tous les chemins (SDK, NDK, Java) sont corrects

### 7. Erreur : No module named 'kivy'
**Problème** : Kivy n'est pas installé.
**Solution** : `pip install kivy==2.1.0`

### 8. Problème : L'APK est trop gros
**Solution** : 
- Utiliser `opencv-python-headless` au lieu de `opencv-python`
- Supprimer les dépendances inutiles de `requirements.txt`

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
| **Facilité de build** | ⭐⭐⭐⭐⭐ | ⭐⭐ |

## 🤝 Contribution

Les contributions sont les bienvenues ! Ouvrez une Pull Request pour proposer vos améliorations.

## 📜 Licence

Ce projet est sous licence MIT, comme la version Flutter.
