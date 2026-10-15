#!/usr/bin/env bash
# local.sh — exécute en local les mêmes étapes que la CI GitHub Actions :
#   lint  : shellcheck + bash -n sur tous les scripts
#   check : structure du dépôt + rapport d'environnement
#   build : lint + check + rapport d'artefact (build/report.txt)
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091  # chemin dynamique, common.sh est linté séparément
source "${SCRIPT_DIR}/../scripts/lib/common.sh"

# list_scripts — liste les scripts .sh du projet (git d'abord, find sinon).
list_scripts() {
  if git -C "${PHPFORGE_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "${PHPFORGE_ROOT}" ls-files '*.sh'
  else
    (
      cd "${PHPFORGE_ROOT}"
      find . -name '*.sh' -type f -not -path './build/*' | sed 's|^\./||'
    )
  fi
}

run_lint() {
  require_cmd shellcheck bash
  local scripts=()
  local script
  # mapfile absent de bash 3.2 (macOS) : lecture portable.
  while IFS= read -r script; do
    [[ -n "${script}" ]] && scripts+=("${script}")
  done < <(list_scripts)
  if [[ "${#scripts[@]}" -eq 0 ]]; then
    die "aucun script .sh trouvé"
  fi
  log_info "analyse de ${#scripts[@]} script(s)"
  shellcheck -x "${scripts[@]}"
  for script in "${scripts[@]}"; do
    bash -n "${PHPFORGE_ROOT}/${script}"
  done
  log_ok "lint : shellcheck + bash -n sans erreur"
}

run_check() {
  require_cmd git make
  "${PHPFORGE_ROOT}/scripts/validate-tree.sh"
  log_info "hôte de build : $(host_os)/$(host_arch)"
  # Décision D004 : les builds lourds (noyau, mkimage) tourneront dans des
  # conteneurs Linux x86_64 ; on prévient si l'hôte n'est pas adapté.
  if [[ "$(host_os)" != "linux" || "$(host_arch)" != "x86_64" ]]; then
    log_warn "hôte non linux/x86_64 : les builds lourds passeront par Docker (D004)"
  fi
  log_ok "check : structure et environnement validés"
}

run_build() {
  run_lint
  run_check
  mkdir -p "${PHPFORGE_ROOT}/build"
  {
    echo "PHPForge OS — rapport de build local"
    echo "date : $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "hôte : $(host_os)/$(host_arch)"
    echo "scripts validés :"
    list_scripts | sed 's/^/  - /'
  } >"${PHPFORGE_ROOT}/build/report.txt"
  log_ok "build : rapport écrit dans build/report.txt"
}

main() {
  local step="${1:-}"
  case "${step}" in
    lint) run_lint ;;
    check) run_check ;;
    build) run_build ;;
    *)
      die "usage : ${0} {lint|check|build}"
      ;;
  esac
}

main "$@"
