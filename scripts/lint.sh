#!/usr/bin/env bash
# lint.sh — exécute shellcheck sur tous les scripts shell (*.sh) du dépôt.
# Ne sont analysés que les fichiers NON ignorés par git (respect de
# .gitignore : caches, artefacts, sources tierces téléchargées comme
# .cache/check-config.sh de Moby).
# Sort non nulle si shellcheck est absent ou si un script échoue.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "erreur : shellcheck introuvable." >&2
    echo "  macOS  : brew install shellcheck" >&2
    echo "  Debian : sudo apt-get install shellcheck" >&2
    exit 127
fi

# Liste des scripts à analyser :
# - dans un dépôt git : fichiers suivis + non suivis non ignorés
#   (git ls-files --exclude-standard respecte .gitignore) ;
# - hors dépôt git : parcours find avec exclusions équivalentes.
list_scripts() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git ls-files -z --cached --others --exclude-standard -- '*.sh'
    else
        find . \( -name .git -o -name build -o -name .cache \
                  -o -name dist -o -name output -o -name aports \
                  -o -name 'linux-*' \) -prune -o \
            -type f -name '*.sh' -print0
    fi
}

found=0
failed=0
# kernel/check-config.sh est un code tiers vendored (Moby, sha256 épinglé
# dans kernel/README.md) : il n'est pas soumis à notre politique de lint.
while IFS= read -r -d '' script; do
    [ "$script" = "kernel/check-config.sh" ] && continue
    found=$((found + 1))
    if ! shellcheck "$script"; then
        failed=$((failed + 1))
    fi
done < <(list_scripts)

echo "shellcheck : ${found} script(s) analysé(s), ${failed} échec(s)."
[[ ${failed} -eq 0 ]]
