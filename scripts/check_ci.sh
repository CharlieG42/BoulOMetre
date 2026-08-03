#!/bin/bash

# =============================================================================
# Script: check_ci.sh
# Description: Surveille automatiquement le build CI après un push
# Usage: ./scripts/check_ci.sh [owner/repo] [branch] [timeout_minutes]
# =============================================================================

set -e

# =============================================================================
# CONFIGURATION PAR DÉFAUT (peut être écrasée par les arguments)
# =============================================================================
REPO="CharlieG42/BoulOMetre"
BRANCH="main"
TIMEOUT_MINUTES=10
POLL_INTERVAL=30  # Secondes entre chaque vérification

# =============================================================================
# COULEURS POUR L'AFFICHAGE
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# FONCTIONS D'AFFICHAGE
# =============================================================================
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# =============================================================================
# FONCTION POUR AFFICHER L'AIDE
# =============================================================================
show_help() {
    echo "Usage: $0 [owner/repo] [branch] [timeout_minutes]"
    echo ""
    echo "Surveille automatiquement le build CI GitHub Actions après un push."
    echo ""
    echo "Arguments:"
    echo "  owner/repo     Dépôt GitHub à surveiller (défaut: $REPO)"
    echo "  branch        Branche à surveiller (défaut: $BRANCH)"
    echo "  timeout_minutes Timeout en minutes (défaut: $TIMEOUT_MINUTES)"
    echo ""
    echo "Exemples:"
    echo "  $0                    # Utilise les valeurs par défaut"
    echo "  $0 myorg/myrepo main 5  # Surveille myorg/myrepo, branche main, timeout 5 min"
    echo ""
    echo "Commandes utiles:"
    echo "  gh run list --repo $REPO --limit 5  # Liste les 5 derniers workflows"
    echo "  gh run view <RUN_ID> --log | tail -100  # Affiche les logs d'un workflow"
}

# =============================================================================
# VÉRIFIER LES PRÉREQUIS
# =============================================================================
check_prerequisites() {
    # Vérifier que gh CLI est installé
    if ! command -v gh &> /dev/null; then
        log_error "gh CLI n'est pas installé. Installez-le depuis https://cli.github.com/"
        exit 1
    fi
    
    # Vérifier que jq est installé (optionnel mais utile)
    if ! command -v jq &> /dev/null; then
        log_warning "jq n'est pas installé. Certaines fonctionnalités seront limitées."
    fi
    
    # Vérifier l'authentification GitHub
    if ! gh auth status &> /dev/null; then
        log_error "Vous n'êtes pas authentifié avec GitHub CLI. Exécutez 'gh auth login'"
        exit 1
    fi
    
    log_info "Prérequis vérifiés avec succès"
}

# =============================================================================
# RÉCUPÉRER L'ID DU DERNIER WORKFLOW
# =============================================================================
get_latest_run_id() {
    local owner_repo=$1
    local branch=$2
    
    # Récupérer le dernier workflow pour la branche spécifiée
    local run_id=$(gh run list --repo "$owner_repo" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null)
    
    if [ -z "$run_id" ]; then
        # Essayer sans jq
        run_id=$(gh run list --repo "$owner_repo" --limit 1 | awk '{print $7}' | head -1)
    fi
    
    echo "$run_id"
}

# =============================================================================
# VÉRIFIER LE STATUT D'UN WORKFLOW
# =============================================================================
get_run_status() {
    local owner_repo=$1
    local run_id=$2
    
    # Récupérer le statut du workflow
    local status=$(gh run view --repo "$owner_repo" "$run_id" --json conclusion --jq '.conclusion' 2>/dev/null)
    
    if [ -z "$status" ]; then
        # Essayer sans jq
        status=$(gh run view --repo "$owner_repo" "$run_id" | grep -E "(success|failure|cancelled|timed_out)" | head -1 | awk '{print $2}')
    fi
    
    echo "$status"
}

# =============================================================================
# RÉCUPÉRER L'URL DE L'ARTIFACT (si build réussi)
# =============================================================================
get_artifact_url() {
    local owner_repo=$1
    local run_id=$2
    
    # Récupérer l'URL de l'artifact
    local artifact_url=$(gh api repos/"$owner_repo"/actions/runs/"$run_id"/artifacts | jq -r '.artifacts[0].archive_download_url' 2>/dev/null)
    
    echo "$artifact_url"
}

# =============================================================================
# AFFICHER LES LOGS D'UN WORKFLOW (dernières lignes)
# =============================================================================
show_run_logs() {
    local owner_repo=$1
    local run_id=$2
    local lines=$3
    
    log_info "Récupération des logs du workflow $run_id..."
    gh run view --repo "$owner_repo" "$run_id" --log | tail -${lines:-100}
}

# =============================================================================
# AFFICHER LES ERREURS D'UN WORKFLOW
# =============================================================================
show_run_errors() {
    local owner_repo=$1
    local run_id=$2
    
    log_info "Recherche des erreurs dans le workflow $run_id..."
    gh run view --repo "$owner_repo" "$run_id" --log | grep -i -E "(error|exception|failed|undefined|not found)" | head -20
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================
main() {
    # Analyser les arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                # Premier argument = owner/repo
                if [ -z "$REPO_OVERRIDE" ]; then
                    REPO_OVERRIDE="$1"
                # Deuxième argument = branch
                elif [ -z "$BRANCH_OVERRIDE" ]; then
                    BRANCH_OVERRIDE="$1"
                # Troisième argument = timeout
                elif [ -z "$TIMEOUT_OVERRIDE" ]; then
                    TIMEOUT_OVERRIDE="$1"
                fi
                ;;
        esac
        shift
    done
    
    # Appliquer les overrides
    REPO=${REPO_OVERRIDE:-$REPO}
    BRANCH=${BRANCH_OVERRIDE:-$BRANCH}
    TIMEOUT_MINUTES=${TIMEOUT_OVERRIDE:-$TIMEOUT_MINUTES}
    
    log_info "Surveillance du build CI pour $REPO (branche: $BRANCH)"
    log_info "Timeout: $TIMEOUT_MINUTES minutes"
    
    # Vérifier les prérequis
    check_prerequisites
    
    # Convertir le timeout en secondes
    local end_time=$(( $(date +%s) + TIMEOUT_MINUTES * 60 ))
    local run_id=""
    local status=""
    local first_check=true
    
    log_info "Attente du démarrage du workflow..."
    
    while [ $(date +%s) -lt $end_time ]; do
        # Récupérer l'ID du dernier workflow
        run_id=$(get_latest_run_id "$REPO" "$BRANCH")
        
        if [ -n "$run_id" ]; then
            if [ "$first_check" = true ]; then
                log_info "Workflow trouvé: $run_id"
                first_check=false
            fi
            
            # Récupérer le statut
            status=$(get_run_status "$REPO" "$run_id")
            
            if [ -n "$status" ]; then
                case "$status" in
                    "success")
                        log_success "Build réussi ! (run ID: $run_id)"
                        
                        # Récupérer l'URL de l'artifact
                        local artifact_url=$(get_artifact_url "$REPO" "$run_id")
                        if [ -n "$artifact_url" ]; then
                            log_info "Artifact disponible: $artifact_url"
                        fi
                        
                        exit 0
                        ;;
                    "failure")
                        log_error "Build échoué ! (run ID: $run_id)"
                        log_error "Affichage des erreurs..."
                        show_run_errors "$REPO" "$run_id"
                        exit 1
                        ;;
                    "cancelled"|"timed_out")
                        log_error "Build annulé ou timeout ! (run ID: $run_id)"
                        exit 1
                        ;;
                    *)
                        # Statut en cours (null, queued, in_progress, etc.)
                        if [ "$status" != "null" ]; then
                            log_info "Build en cours... (statut: $status)"
                        fi
                        ;;
                esac
            fi
        else
            if [ "$first_check" = true ]; then
                log_info "Aucun workflow trouvé pour $REPO/$BRANCH. Attente..."
            fi
        fi
        
        # Attendre avant la prochaine vérification
        sleep $POLL_INTERVAL
    done
    
    log_error "Timeout atteint après $TIMEOUT_MINUTES minutes"
    exit 1
}

# =============================================================================
# EXÉCUTION DU SCRIPT
# =============================================================================
main "$@"
