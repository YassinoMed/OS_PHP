#!/usr/bin/env bash
# check-tree.sh — vérifie que l'arborescence et les fichiers requis par la
# méthode de développement PHPForge OS (voir PROGRESS.md) sont présents.
set -euo pipefail

cd "$(dirname "$0")/.."

required_files=(
    DECISIONS.md
    PROGRESS.md
    README.md
    Makefile
    .gitignore
    .github/workflows/ci.yml
    scripts/lint.sh
    scripts/check-tree.sh
)

# Un répertoire par phase de PROGRESS.md (P1 à P9) + outillage.
required_dirs=(
    kernel
    console
    php
    laravel
    desktop
    manager
    installer
    compat
    buildroot
    scripts
)

status=0

for f in "${required_files[@]}"; do
    if [[ -f "$f" ]]; then
        echo "ok : $f"
    else
        echo "MANQUANT (fichier) : $f"
        status=1
    fi
done

for d in "${required_dirs[@]}"; do
    if [[ -d "$d" ]]; then
        echo "ok : $d/"
    else
        echo "MANQUANT (répertoire) : $d/"
        status=1
    fi
done

if [[ ${status} -eq 0 ]]; then
    echo "Arborescence conforme."
else
    echo "Arborescence incomplète." >&2
fi
exit ${status}
