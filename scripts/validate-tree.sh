#!/usr/bin/env bash
# validate-tree.sh — vérifie la structure minimale du dépôt PHPForge OS.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091  # chemin dynamique, common.sh est linté séparément
source "${SCRIPT_DIR}/lib/common.sh"

REQUIRED_DIRS=(
  "ci"
  "scripts/lib"
  ".github/workflows"
)

REQUIRED_FILES=(
  "README.md"
  "PROGRESS.md"
  "DECISIONS.md"
  "Makefile"
  ".gitignore"
  "ci/local.sh"
  "scripts/lib/common.sh"
  "scripts/validate-tree.sh"
  ".github/workflows/ci.yml"
)

main() {
  local item rc=0

  for item in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "${PHPFORGE_ROOT}/${item}" ]]; then
      log_info "répertoire présent : ${item}"
    else
      log_error "répertoire manquant : ${item}"
      rc=1
    fi
  done

  for item in "${REQUIRED_FILES[@]}"; do
    if [[ -f "${PHPFORGE_ROOT}/${item}" ]]; then
      log_info "fichier présent : ${item}"
    else
      log_error "fichier manquant : ${item}"
      rc=1
    fi
  done

  if [[ "${rc}" -eq 0 ]]; then
    log_ok "structure du dépôt valide"
  else
    log_error "structure du dépôt invalide"
  fi
  return "${rc}"
}

main "$@"
