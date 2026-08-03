# 📋 Checklist de Développement Flutter - Bonnes Pratiques

*Document générique applicable à tous les projets Flutter. À adapter selon les besoins spécifiques.*

---

## 🚀 Table des Matières

1. [Avant de Commencer](#avant-de-commencer)
2. [Pendant le Développement](#pendant-le-développement)
3. [Avant de Commiter](#avant-de-commiter)
4. [Après le Commit](#après-le-commit)
5. [Gestion des Erreurs Courantes](#gestion-des-erreurs-courantes)
6. [Bonnes Pratiques Générales](#bonnes-pratiques-générales)
7. [Ressources Utiles](#ressources-utiles)

---

## 📝 Avant de Commencer

### Configuration de l'Environnement

- [ ] **Flutter SDK** : Vérifier la version (`flutter --version`)
  - Utiliser une version **stable** (ex: 3.22.x)
  - Éviter les versions en développement (`dev` ou `master`)
  
- [ ] **Dépendances** : Exécuter `flutter pub get`
  - Vérifier que toutes les dépendances sont résolues
  - Mettre à jour le `pubspec.yaml` si nécessaire

- [ ] **Android/iOS** : Configurer les plateformes cibles
  - Android : Vérifier `compileSdkVersion`, `minSdkVersion`, etc.
  - iOS : Vérifier la configuration Xcode

- [ ] **Outils** : Installer les outils nécessaires
  - `dart` (inclus avec Flutter)
  - `gh` (GitHub CLI) pour les opérations GitHub
  - `jq` pour parser le JSON (optionnel mais utile)

---

## 💻 Pendant le Développement

### Structure du Code

- [ ] **Organisation des fichiers** :
  - `lib/` : Code source principal
  - `lib/models/` : Modèles de données
  - `lib/services/` : Logique métier et services
  - `lib/screens/` : Écrans (widgets de page)
  - `lib/widgets/` : Composants réutilisables
  - `lib/utils/` : Utilitaires et helpers

- [ ] **Nommage** :
  - Utiliser `snake_case` pour les fichiers (`camera_screen.dart`)
  - Utiliser `PascalCase` pour les classes (`CameraScreen`)
  - Utiliser `camelCase` pour les variables et méthodes (`captureAndProcess`)

- [ ] **Imports** :
  - **Toujours vérifier** que tous les types utilisés sont importés
  - Regrouper les imports par catégorie :
    ```dart
    // 1. Imports Dart
    import 'dart:math';
    import 'dart:typed_data';
    import 'dart:async';
    
    // 2. Imports Flutter
    import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
    
    // 3. Imports de packages tiers
    import 'package:camera/camera.dart';
    import 'package:image/image.dart' as img;
    
    // 4. Imports locaux
    import 'package:mon_projet/models/ball.dart';
    import 'package:mon_projet/services/camera_service.dart';
    ```

### Types et Null Safety

- [ ] **Types explicites** : Éviter `var` pour les propriétés et états
  - ❌ `var myList = [];` → ✅ `List<String> myList = [];`
  
- [ ] **Null Safety** :
  - Utiliser `?` pour les types nullable
  - Utiliser `!` uniquement si vous êtes **certain** que la valeur n'est pas null
  - Préférer les vérifications explicites :
    ```dart
    // ❌ À éviter
    final value = nullableList.firstOrNull;
    
    // ✅ Préférer
    final value = nullableList.isNotEmpty ? nullableList.first : null;
    ```

- [ ] **Types courants** :
  | Type | Import | Utilisation |
  |------|--------|-------------|
  | `Uint8List` | `dart:typed_data` | Images, bytes |
  | `sqrt`, `min`, `pi`, `cos`, `sin` | `dart:math` | Calculs mathématiques |
  | `Future` | `dart:async` | Opérations asynchrones |

---

## 🔍 Avant de Commiter

### Vérifications Locales

- [ ] **Analyse statique** : Exécuter `flutter analyze`
  - Corriger toutes les erreurs et warnings
  - Utiliser `--no-fatal-warnings` pour bloquer sur les warnings

- [ ] **Tests unitaires** : Exécuter `flutter test`
  - Tous les tests doivent passer
  - Ajouter des tests pour les nouvelles fonctionnalités

- [ ] **Build local** : Tester `flutter build apk` ou `flutter build ios`
  - Vérifier que le build réussit localement
  - Tester sur un appareil si possible

### Vérifications du Code

- [ ] **Imports** : Tous les types utilisés sont-ils importés ?
- [ ] **Types nullables** : La null safety est-elle respectée ?
- [ ] **Nommage** : Les conventions de nommage sont-elles respectées ?
- [ ] **Commentaires** : Le code est-il bien documenté ?
  - Commenter les méthodes complexes
  - Documenter les paramètres et retours

### Message de Commit

- [ ] **Format** : Utiliser des messages clairs et descriptifs
  - ❌ `fix: stuff` → ✅ `fix: corrige l'erreur de type Uint8List manquant`
  - Utiliser le format **Conventional Commits** :
    - `feat:` : Nouvelle fonctionnalité
    - `fix:` : Correction de bug
    - `docs:` : Documentation
    - `style:` : Changements de style (formatage, etc.)
    - `refactor:` : Refactorisation
    - `test:` : Ajout/modification de tests
    - `chore:` : Tâches de maintenance

- [ ] **Référence** : Lier à une issue si applicable (`Closes #123`)

---

## 🤖 Après le Commit (CI/CD)

### Surveillance du Build CI

- [ ] **Attendre la fin du build** (2-3 minutes)
  - Ne **jamais** considérer le travail terminé avant la réussite du CI

- [ ] **Vérifier le statut** :
  ```bash
  # Lister les derniers workflows
  gh run list --repo OWNER/REPO --limit 3
  
  # Voir les détails d'un workflow
  gh run view --repo OWNER/REPO <RUN_ID> --log
  ```

- [ ] **Si le build échoue** :
  1. Lire les logs du workflow
  2. Identifier l'erreur (généralement dans les dernières lignes)
  3. Corriger l'erreur **immédiatement**
  4. Recommiter et repousser

### Erreurs CI Courantes

| Erreur | Cause Probable | Solution |
|--------|----------------|----------|
| `Type 'X' not found` | Import manquant | Ajouter l'import correspondant |
| `The method 'X' isn't defined` | Type ou méthode incorrect | Vérifier l'API du package |
| `A value of type 'X?' can't be assigned to 'X'` | Null safety | Utiliser `!` ou vérifier la nullabilité |
| `Target kernel_snapshot failed` | Erreur de compilation Dart | Vérifier les imports et types |

---

## 🛠️ Gestion des Erreurs Courantes

### 1. Erreurs de Type

#### `Uint8List` non trouvé
```dart
// ❌ Erreur
Uint8List? _capturedImageBytes;

// ✅ Solution
import 'dart:typed_data';
Uint8List? _capturedImageBytes;
```

#### Fonctions mathématiques non trouvées (`sqrt`, `min`, `pi`, etc.)
```dart
// ❌ Erreur
final distance = sqrt(x * x + y * y);

// ✅ Solution
import 'dart:math';
final distance = sqrt(x * x + y * y);
```

### 2. Null Safety

#### `firstWhere` avec `orElse` incompatible
```dart
// ❌ Erreur : orElse retourne null mais le type attendu est Ball
final piglet = balls.firstWhere((b) => b.isPiglet, orElse: () => null);

// ✅ Solution 1 : Vérification préalable
if (balls.isEmpty || !balls.any((b) => b.isPiglet)) return;
final piglet = balls.firstWhere((b) => b.isPiglet);

// ✅ Solution 2 : Utiliser firstWhereOrNull (nécessite package:collection)
final piglet = balls.firstWhereOrNull((b) => b.isPiglet);
```

#### Accès à des propriétés sur des types nullable
```dart
// ❌ Erreur : ball pourrait être null
final x = ball.x;

// ✅ Solution 1 : Utiliser ! si certain
final x = ball!.x;  // Seulement si vous êtes SÛR que ball n'est pas null

// ✅ Solution 2 : Vérification préalable
if (ball != null) {
  final x = ball.x;
}

// ✅ Solution 3 : Opérateur conditionnel
final x = ball?.x ?? 0.0;
```

### 3. Accès aux Arguments de Route

#### Arguments non récupérés dans les routes
```dart
// ❌ Erreur : Arguments ignorés
routes: {
  '/results': (context) => ResultsScreen(balls: []),
}

// ✅ Solution : Récupérer via ModalRoute
routes: {
  '/results': (context) => ResultsScreen(
    balls: ModalRoute.of(context)!.settings.arguments as List<Ball>? ?? [],
  ),
}
```

### 4. Capteurs et API

#### `AccelerometerEvent` : `pitch`/`roll` non définis
```dart
// ❌ Erreur : AccelerometerEvent n'a pas pitch/roll
accelerometerEvents.listen((event) {
  final pitch = event.pitch;  // ❌ Erreur
  final roll = event.roll;    // ❌ Erreur
});

// ✅ Solution : Utiliser x, y, z
accelerometerEvents.listen((event) {
  // Pour un niveau à bulle simple, x et y suffisent
  final roll = event.x;   // ✅ Inclinaison latérale
  final pitch = event.y;  // ✅ Inclinaison avant/arrière
});
```

---

## ✨ Bonnes Pratiques Générales

### 1. Gestion d'État

- [ ] **Utiliser `setState` correctement** :
  - Toujours vérifier `mounted` avant `setState` dans les callbacks asynchrones
  ```dart
  if (mounted) {
    setState(() { ... });
  }
  ```

- [ ] **Éviter les rebuilds inutiles** :
  - Utiliser `const` pour les widgets immutables
  - Utiliser `Key` pour optimiser les performances

### 2. Gestion des Images

- [ ] **Libérer les ressources** :
  - Nettoyer les `Uint8List` et `Image` après utilisation
  ```dart
  // Dans _cancelMeasurement
  setState(() {
    _capturedImageBytes = null;  // Libérer la mémoire
  });
  ```

- [ ] **Affichage optimisé** :
  - Utiliser `BoxFit.cover` ou `BoxFit.contain` selon le besoin
  - Utiliser `Positioned.fill` pour les images en plein écran

### 3. UX/UI

- [ ] **Feedback visuel** :
  - Toujours indiquer à l'utilisateur ce qu'il doit faire
  - Utiliser des `SnackBar` pour les messages temporaires
  - Utiliser des indicateurs de chargement (`CircularProgressIndicator`)

- [ ] **Gestion des erreurs** :
  - Afficher des messages d'erreur clairs
  - Ne pas laisser l'application planter silencieusement

### 4. Performance

- [ ] **Éviter les calculs coûteux dans `build`** :
  - Pré-calculer les valeurs dans `initState` ou via des variables d'état

- [ ] **Utiliser `const`** :
  - Pour les widgets et valeurs immutables

- [ ] **Lazy loading** :
  - Charger les ressources (images, données) à la demande

---

## 📚 Ressources Utiles

### Commandes Flutter Utiles

| Commande | Description |
|----------|-------------|
| `flutter analyze` | Analyse statique du code |
| `flutter test` | Exécute les tests unitaires |
| `flutter build apk` | Build APK Android |
| `flutter build ios` | Build iOS |
| `flutter pub get` | Télécharge les dépendances |
| `flutter pub upgrade` | Met à jour les dépendances |
| `flutter clean` | Nettoie le cache |

### Commandes GitHub CLI Utiles

| Commande | Description |
|----------|-------------|
| `gh run list --limit 5` | Liste les 5 derniers workflows |
| `gh run view <ID> --log` | Affiche les logs d'un workflow |
| `gh run view <ID> --json status` | Récupère le statut au format JSON |
| `gh api repos/OWNER/REPO/actions/runs` | Liste les runs via API |

### Outils de Debug

- [ ] **Flutter DevTools** :
  - Inspection des widgets
  - Profiling des performances
  - Debug du réseau

- [ ] **Logs Android** :
  ```bash
  adb logcat | grep flutter
  ```

- [ ] **Logs iOS** :
  ```bash
  idevicesyslog | grep flutter
  ```

---

## 📌 Checklist Rapide Avant Push

```
□ Code compilé localement (flutter analyze)
□ Tests unitaires passés (flutter test)
□ Build local réussi (flutter build apk/ios)
□ Tous les imports sont présents
□ Null safety respectée
□ Message de commit clair et descriptif
□ Lien à une issue si applicable (Closes #123)
□ **Attendre la réussite du CI GitHub Actions** ← CRITIQUE
```

---

## 🎯 Résumé des Étapes Clés

```
1. Développer la fonctionnalité
   ↓
2. Vérifier les imports et types
   ↓
3. Tester localement (analyze, test, build)
   ↓
4. Commiter avec message clair
   ↓
5. Pousser vers la branche
   ↓
6. **ATTENDRE LE CI** ← NE PAS OUBLIER
   ↓
7. Si échec → Lire logs → Corriger → Recommiter
   ↓
8. Si succès → Célébrer ! 🎉
```

---

## 📝 Historique des Corrections (Exemple)

| Date | Problème | Solution | Commit |
|------|----------|----------|--------|
| 2026-08-02 | `Uint8List` non trouvé | Ajout `import 'dart:typed_data'` | 61a978c |
| 2026-08-02 | `sqrt/min/pi` non trouvés | Ajout `import 'dart:math'` | 4eb17c4 |
| 2026-08-02 | `pitch/roll` non définis | Utiliser `x` et `y` de `AccelerometerEvent` | 7ce6070 |
| 2026-08-02 | Image non affichée après capture | Afficher `Image.memory` au lieu de `CameraPreview` | 4319b36 |

---

## 🔗 Liens Utiles

- [Documentation Flutter](https://docs.flutter.dev/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Null Safety en Dart](https://dart.dev/null-safety)
- [GitHub Actions pour Flutter](https://github.com/marketplace?type=actions&query=flutter)

---

*Ce document est générique et peut être adapté pour n'importe quel projet Flutter.*
*Mettez à jour cette checklist selon les besoins spécifiques de votre projet.*
