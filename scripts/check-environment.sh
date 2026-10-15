#!/usr/bin/env bash
# check-environment.sh — vérifie les outils requis par phase.
# Sortie 0 si les outils requis à la phase courante (P0) sont présents.
# Les outils des phases ultérieures sont rapportés en WARNING sans faire échouer.
#
# Usage : ./scripts/check-environment.sh [--all]
#   --all : échoue aussi si un outil d'une phase future manque (utilisé en CI).

set -euo pipefail

readonly SCRIPT_NAME="${0##*/}"
OPT_ALL=0
if [[ "${1:-}" == "--all" ]]; then
    OPT_ALL=1
elif [[ $# -gt 0 ]]; then
    echo "Usage : ${SCRIPT_NAME} [--all]" >&2
    exit 2
fi

# tool <nom> <variable-test> <phase> <commentaire>
# Vérifie qu'une commande est disponible sur le PATH.
check_tool() {
    local name="$1" phase="$2" comment="${3:-}"
    if command -v "$name" >/dev/null 2>&1; then
        printf '  [OK]      %-22s (%s) %s\n' "$name" "$phase" "$comment"
        return 0
    fi
    if [[ "$phase" == "P0" ]]; then
        printf '  [MISSING] %-22s (%s) %s — REQUIS\n' "$name" "$phase" "$comment" >&2
        return 1
    fi
    if [[ $OPT_ALL -eq 1 ]]; then
        printf '  [MISSING] %-22s (%s) %s — requis avec --all\n' "$name" "$phase" "$comment" >&2
        return 1
    fi
    printf '  [WARN]    %-22s (%s) %s — requis plus tard\n' "$name" "$phase" "$comment"
    return 0
}

declare -a MISSING=()
declare -i FAILED=0

group() {
    printf '\n== %s ==\n' "$1"
}

group "Phase P0 — Dépôt / CI"
for t in "git:contrôle de versions" \
         "make:moteur de build" \
         "shellcheck:lint des scripts"; do
    name="${t%%:*}" comment="${t#*:}"
    check_tool "$name" "P0" "$comment" || {
        MISSING+=("$name")
        FAILED=1
    }
done

group "Phase P1 — Noyau (requis seulement pour build-kernel.sh)"
for t in "curl:téléchargement des sources" \
         "gcc:compilation" \
         "flex:compilation noyau" \
         "bison:compilation noyau" \
         "make:compilation noyau" \
         "bc:compilation noyau" \
         "perl:compilation noyau" \
         "rsync:staging"; do
    name="${t%%:*}" comment="${t#*:}"
    check_tool "$name" "P1" "$comment" || {
        MISSING+=("$name")
        [[ $OPT_ALL -eq 1 ]] && FAILED=1
    }
done

group "Phase P2 — Console (mkimage + QEMU)"
for t in "qemu-system-x86_64:boot QEMU UEFI" \
         "qemu-img:création des disques" \
         "bash:scripts d'init" \
         "wget:mkimage (optionnel selon setup)"; do
    name="${t%%:*}" comment="${t#*:}"
    check_tool "$name" "P2" "$comment" || {
        MISSING+=("$name")
        [[ $OPT_ALL -eq 1 ]] && FAILED=1
    }
done

printf '\n'
if [[ $FAILED -eq 1 ]]; then
    {
        printf 'ÉCHEC : outils manquants requis : %s\n' "${MISSING[*]}"
        printf 'Installez-les puis relancez %s\n' "$SCRIPT_NAME"
    } >&2
    exit 1
fi
printf 'Environnement OK pour la phase courante (P0).'
[[ ${#MISSING[@]} -gt 0 ]] && printf ' %d outil(s) manquant(s) pour les phases futures (normal).' "${#MISSING[@]}"
printf '\n'
exit 0
