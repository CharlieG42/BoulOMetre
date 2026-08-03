#!/bin/bash

# =============================================================================
# Script simplifié pour vérifier le CI
# Utilisation: ./scripts/ci-check.sh
# =============================================================================

# Charger la configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Exécuter le script principal avec la configuration
"$SCRIPT_DIR/check_ci.sh" "$REPO" "$BRANCH" "$TIMEOUT_MINUTES"
