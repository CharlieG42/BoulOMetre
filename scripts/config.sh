#!/bin/bash

# =============================================================================
# Configuration pour les scripts de développement
# =============================================================================

# Dépôt GitHub (format: owner/repo)
REPO="CharlieG42/BoulOMetre"

# Branche par défaut à surveiller
BRANCH="main"

# Timeout par défaut en minutes
TIMEOUT_MINUTES=10

# Intervalle de vérification en secondes
POLL_INTERVAL=30

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'  # No Color

# =============================================================================
# NE PAS MODIFIER CI-DESSOUS (utilisé par les scripts)
# =============================================================================

# Chemin vers le script principal
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
