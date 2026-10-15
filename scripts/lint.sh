#!/usr/bin/env bash
# lint.sh — exécute shellcheck sur tous les scripts shell (*.sh) du dépôt.
# Sort non nulle si shellcheck est absent ou si un script échoue.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v shellcheck >/dev/null 2>&1; then
    echo "erreur : shellcheck introuvable." >&2
    echo "  macOS  : brew install shellcheck" >&2
    echo "  Debian : sudo apt-get install shellcheck" >&2
    exit 127
fi

found=0
failed=0
while IFS= read -r -d '' script; do
    found=$((found + 1))
    if ! shellcheck "$script"; then
        failed=$((failed + 1))
    fi
done < <(find . \( -name .git -o -name build \) -prune -o \
    -type f -name '*.sh' -print0)

echo "shellcheck : ${found} script(s) analysé(s), ${failed} échec(s)."
[[ ${failed} -eq 0 ]]
