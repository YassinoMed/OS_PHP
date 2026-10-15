#!/usr/bin/env bash
# common.sh — helpers partagés de PHPForge OS.
# shellcheck shell=bash

# Racine du dépôt (common.sh vit dans scripts/lib/).
PHPFORGE_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
export PHPFORGE_ROOT

log_info() { printf '[phpforge] [info] %s\n' "$*"; }
log_ok() { printf '[phpforge] [ok] %s\n' "$*"; }
log_warn() { printf '[phpforge] [warn] %s\n' "$*" >&2; }
log_error() { printf '[phpforge] [erreur] %s\n' "$*" >&2; }

die() {
  log_error "$*"
  exit 1
}

# require_cmd git make — échoue avec un message clair si une commande manque.
require_cmd() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "commande requise introuvable : $cmd"
  done
}

# host_os — macos | linux | autre (minuscules).
host_os() {
  local os
  os="$(uname -s)"
  printf '%s' "$(printf '%s' "${os}" | tr '[:upper:]' '[:lower:]')"
}

# host_arch — x86_64 | aarch64 | brut sinon.
host_arch() {
  case "$(uname -m)" in
    x86_64 | amd64) printf 'x86_64' ;;
    aarch64 | arm64) printf 'aarch64' ;;
    *) printf '%s' "$(uname -m)" ;;
  esac
}
