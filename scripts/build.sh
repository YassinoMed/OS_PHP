#!/usr/bin/env bash
# build.sh — build de la phase P0.
# 1. Vérifie l'environnement (outils requis P0).
# 2. Valide l'arborescence du dépôt (fichiers/dossiers requis).
# 3. Génère build/manifest.txt : version, commit git, liste des fichiers
#    du dépôt avec sommes de contrôle SHA-256.
#
# Usage : ./scripts/build.sh [--skip-env]
#   --skip-env : ne pas relancer check-environment.sh (utile en CI où le
#                contrôle a déjà été fait).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT
readonly BUILD_DIR="${REPO_ROOT}/build"
readonly MANIFEST="${BUILD_DIR}/manifest.txt"
readonly VERSION_FILE="${REPO_ROOT}/VERSION"

OPT_SKIP_ENV=0
if [[ "${1:-}" == "--skip-env" ]]; then
    OPT_SKIP_ENV=1
elif [[ $# -gt 0 ]]; then
    echo "Usage : ${0##*/} [--skip-env]" >&2
    exit 2
fi

log()  { printf '[build] %s\n' "$*"; }
fail() { printf '[build] ERREUR : %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- environnement
if [[ $OPT_SKIP_ENV -eq 0 ]]; then
    log "Vérification de l'environnement (phase P0)..."
    "${REPO_ROOT}/scripts/check-environment.sh"
fi

# ---------------------------------------------------------------------- arbre
readonly REQUIRED_DIRS=(
    .github/workflows
    config/kernel
    config/alpine
    config/php
    config/manager
    docs
    scripts
    tests
)
readonly REQUIRED_FILES=(
    .github/workflows/ci.yml
    .gitignore
    DECISIONS.md
    LICENSE
    Makefile
    PROGRESS.md
    README.md
    VERSION
    scripts/build.sh
    scripts/check-environment.sh
    tests/test_p0.sh
)

log "Validation de l'arborescence..."
cd "$REPO_ROOT"
for d in "${REQUIRED_DIRS[@]}"; do
    [[ -d "$d" ]] || fail "dossier requis manquant : $d/"
done
for f in "${REQUIRED_FILES[@]}"; do
    [[ -f "$f" ]] || fail "fichier requis manquant : $f"
done
log "Arborescence OK (${#REQUIRED_DIRS[@]} dossiers, ${#REQUIRED_FILES[@]} fichiers clés)."

# ------------------------------------------------------------------ manifeste
[[ -f "$VERSION_FILE" ]] || fail "VERSION introuvable"
PHPFORGE_VERSION="$(tr -d '[:space:]' < "$VERSION_FILE")"
[[ -n "$PHPFORGE_VERSION" ]] || fail "VERSION vide"
readonly PHPFORGE_VERSION

GIT_COMMIT="non-versionné"
GIT_BRANCH="-"
GIT_DIRTY=""
if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    GIT_COMMIT="$(git -C "$REPO_ROOT" rev-parse HEAD)"
    GIT_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
    if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)"" ]]; then
        GIT_DIRTY=" (workdir sale)"
    fi
fi

hash_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        cksum "$1" | awk '{print $1}'
    fi
}

log "Génération de ${MANIFEST#${REPO_ROOT}/} ..."
mkdir -p "$BUILD_DIR"
{
    echo "phpforge-os build manifest"
    echo "========================="
    echo "version    : ${PHPFORGE_VERSION}"
    echo "built-at   : $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "built-on   : $(uname -s) $(uname -m) ($(uname -r))"
    echo "git-branch : ${GIT_BRANCH}"
    echo "git-commit : ${GIT_COMMIT}${GIT_DIRTY}"
    echo "shell      : bash ${BASH_VERSION}"
    echo ""
    echo "Contenu du dépôt (chemin  sha256) :"
    # Fichiers suivis par git si possible, sinon tous les fichiers hors build/.
    if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
       && [[ -n "$(git -C "$REPO_ROOT" ls-files)" ]]; then
        git -C "$REPO_ROOT" ls-files
    else
        find "$REPO_ROOT" -path "$REPO_ROOT/build" -prune -o \
             -path "$REPO_ROOT/.git" -prune -o -type f -print
    fi
} | while IFS= read -r f; do
    if [[ "$f" == */* ]]; then
        # Ligne de contenu du dépôt : hasher le fichier listé.
        if [[ -f "$REPO_ROOT/$f" ]]; then
            printf '%s  %s\n' "$(hash_file "$REPO_ROOT/$f")" "$f"
        fi
    else
        # Ligne d'en-tête du manifeste : la recopier telle quelle.
        printf '%s\n' "$f"
    fi
done > "$MANIFEST"

readonly MANIFEST_LINES
MANIFEST_LINES="$(wc -l < "$MANIFEST" | tr -d '[:space:]')"
log "Manifeste généré : ${MANIFEST} (${MANIFEST_LINES} lignes)."

# Vérification auto : le manifeste doit contenir les champs clés.
for key in "version" "git-commit" "README.md" "Makefile"; do
    grep -q "$key" "$MANIFEST" || fail "manifeste incomplet : '$key' absent"
done

log "BUILD P0 RÉUSSI."
exit 0
