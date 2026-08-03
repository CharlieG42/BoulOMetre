# 📁 Scripts de Développement

Ce dossier contient des scripts utiles pour automatiser les tâches de développement et de CI/CD.

---

## 📜 Fichiers Disponibles

| Script | Description | Utilisation |
|--------|-------------|-------------|
| [`check_ci.sh`](check_ci.sh) | Surveille automatiquement le build CI après un push | `./scripts/check_ci.sh` |

---

## 🚀 check_ci.sh - Surveillance Automatique du CI

### **Description**
Ce script surveille automatiquement le statut des builds GitHub Actions après un push. Il :
- Attend que le workflow se lance
- Vérifie régulièrement le statut
- Affiche les erreurs si le build échoue
- Fournit le lien de téléchargement de l'APK si le build réussit

### **Utilisation**

#### **1. Exécution basique** (avec les valeurs par défaut)
```bash
./scripts/check_ci.sh
```

#### **2. Avec des paramètres personnalisés**
```bash
./scripts/check_ci.sh [owner/repo] [branch] [timeout_minutes]
```

**Exemples :**
```bash
# Surveille le dépôt actuel, branche main, timeout 10 min
./scripts/check_ci.sh

# Surveille un autre dépôt
./scripts/check_ci.sh monorg/monrepo main 5

# Surveille une autre branche
./scripts/check_ci.sh CharlieG42/BoulOMetre develop 15
```

### **Options**

| Option | Description | Valeur par défaut |
|--------|-------------|-------------------|
| `owner/repo` | Dépôt GitHub à surveiller | `CharlieG42/BoulOMetre` |
| `branch` | Branche à surveiller | `main` |
| `timeout_minutes` | Timeout en minutes | `10` |

### **Exemple de sortie**

**Si le build réussit :**
```
[INFO] Surveillance du build CI pour CharlieG42/BoulOMetre (branche: main)
[INFO] Timeout: 10 minutes
[INFO] Prérequis vérifiés avec succès
[INFO] Workflow trouvé: 30839033029
[INFO] Build en cours... (statut: queued)
[INFO] Build en cours... (statut: in_progress)
[SUCCESS] Build réussi ! (run ID: 30839033029)
[INFO] Artifact disponible: https://github.com/CharlieG42/BoulOMetre/actions/runs/30839033029/artifacts/8866119271
```

**Si le build échoue :**
```
[INFO] Surveillance du build CI pour CharlieG42/BoulOMetre (branche: main)
[INFO] Prérequis vérifiés avec succès
[INFO] Workflow trouvé: 30831837379
[ERROR] Build échoué ! (run ID: 30831837379)
[ERROR] Affichage des erreurs...
[INFO] Recherche des erreurs dans le workflow 30831837379...
lib/widgets/camera_overlay.dart:373:36: Error: Undefined name 'devicePitch'
...
```

### **Prérequis**

1. **GitHub CLI (`gh`)** : Doit être installé et authentifié
   - Installation : [https://cli.github.com/](https://cli.github.com/)
   - Authentification : `gh auth login`

2. **jq** (optionnel) : Pour un meilleur parsing du JSON
   - Installation (Ubuntu/Debian) : `sudo apt-get install jq`
   - Installation (Mac) : `brew install jq`

---

## 📋 Workflow Recommandé

### **Après chaque commit/push :**

```bash
# 1. Faire un commit
git add .
git commit -m "feat: ma nouvelle fonctionnalité"
git push origin main

# 2. Lancer la surveillance du CI
./scripts/check_ci.sh

# 3. Si le build échoue, corriger et recommiter
```

### **Pour une intégration continue :**

Vous pouvez ajouter ce script à votre workflow Git Hooks :

```bash
# Dans .git/hooks/post-push (à rendre exécutable)
#!/bin/sh
./scripts/check_ci.sh &
```

---

## 🔧 Personnalisation

### **Modifier les valeurs par défaut**

Éditez les variables au début du script `check_ci.sh` :

```bash
REPO="monorg/monrepo"         # Dépôt par défaut
BRANCH="develop"              # Branche par défaut
TIMEOUT_MINUTES=15            # Timeout par défaut
POLL_INTERVAL=30              # Intervalle de vérification (secondes)
```

### **Changer les couleurs**

Les couleurs d'affichage peuvent être modifiées dans la section `COULEURS POUR L'AFFICHAGE`.

---

## 📝 Bonnes Pratiques

1. **Toujours surveiller le CI** après un push
2. **Ne pas quitter le terminal** avant la fin du build
3. **Lire les erreurs** si le build échoue
4. **Corriger immédiatement** les problèmes de compilation
5. **Vérifier l'APK** une fois le build réussi

---

## 🎯 Commandes Utiles Manuelles

| Commande | Description |
|----------|-------------|
| `gh run list --repo CharlieG42/BoulOMetre --limit 5` | Liste les 5 derniers workflows |
| `gh run view 30839033029 --log` | Affiche les logs complets d'un workflow |
| `gh run view 30839033029 --log \| tail -50` | Affiche les 50 dernières lignes des logs |
| `gh run view 30839033029 --log \| grep -i error` | Filtre les erreurs dans les logs |
| `gh api repos/CharlieG42/BoulOMetre/actions/runs` | Liste les runs via API |

---

## 📌 Notes

- Ce script est conçu pour fonctionner sur **Linux, MacOS et Windows (avec WSL)**
- Il nécessite **bash** (version 4.0 ou supérieure)
- Pour Windows natif, utilisez **Git Bash** ou **WSL**
- Le script utilise les **API GitHub** via `gh CLI`

---

## 🔗 Liens Utiles

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub Actions API](https://docs.github.com/en/rest/actions)
- [jq Manual](https://stedolan.github.io/jq/manual/)

---

*Ce script fait partie du projet BoulOMetre et peut être adapté pour d'autres projets Flutter.*
