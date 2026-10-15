#!/usr/bin/env bash
# test_p0.sh — tests de la phase P0.
# Vérifie : cibles make, lint shellcheck propre, build fonctionnel et
# manifeste complet, cohérence de VERSION et de la CI.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly REPO_ROOT

pass() { printf '  [PASS] %s\n' "$*"; }
fail() { printf '  [FAIL] %s\n' "$*" >&2; exit 1; }
note() { printf '\n== %s ==\n' "$*"; }

note "T1 : VERSION au format semver"
if grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' "${REPO_ROOT}/VERSION"; then
    pass "VERSION=$(tr -d '[:space:]' < "${REPO_ROOT}/VERSION")"
else
    fail "VERSION ne respecte pas le format X.Y.Z"
fi

note "T2 : tous les scripts .sh passent shellcheck"
cd "$REPO_ROOT"
while IFS= read -r script; do
    if shellcheck "$script"; then
        pass "shellcheck ${script}"
    else
        fail "shellcheck ${script}"
    fi
done < <(find scripts tests -name '*.sh' -type f | sort)

note "T3 : make lint"
make -C "$REPO_ROOT" lint >/dev/null
pass "make lint exit 0"

note "T4 : make build (génère le manifeste)"
rm -rf "${REPO_ROOT}/build"
make -C "$REPO_ROOT" build >/dev/null
[[ -f "${REPO_ROOT}/build/manifest.txt" ]] || fail "build/manifest.txt absent"
pass "build/manifest.txt généré"

note "T5 : contenu du manifeste"
readonly MANIFEST="${REPO_ROOT}/build/manifest.txt"
for key in "version" "built-at" "git-branch" "git-commit" "scripts/build.sh" "README.md"; do
    grep -q "$key" "$MANIFEST" \
        || fail "manifeste incomplet : '$key' introuvable"
    pass "manifeste contient '$key'"
done

note "T6 : make clean supprime build/"
make -C "$REPO_ROOT" clean >/dev/null
[[ ! -d "${REPO_ROOT}/build" ]] || fail "build/ toujours présent après clean"
pass "build/ supprimé"

note "T7 : workflow CI présent et appelant make lint/build/test"
readonly CI="${REPO_ROOT}/.github/workflows/ci.yml"
[[ -f "$CI" ]] || fail "ci.yml absent"
grep -q "make lint"  "$CI" || fail "ci.yml n'appelle pas 'make lint'"
grep -q "make build" "$CI" || fail "ci.yml n'appelle pas 'make build'"
grep -q "make test"  "$CI" || fail "ci.yml n'appelle pas 'make test'"
pass "ci.yml → lint + build + test"

printf '\nTOUS LES TESTS P0 SONT PASSÉS.\n'
exit 0
