# DECISIONS.md — Décisions d'architecture PHPForge OS

Toute modification de ce fichier doit être justifiée dans `PROGRESS.md`
(section Journal : date, tâche, justification, impact).

| ID  | Date       | Domaine        | Décision | Justification |
|-----|------------|----------------|----------|---------------|
| D001 | 2026-10-15 | Distribution | Base **Alpine Linux** construite via `mkimage` (aports officiel). | Légèreté (~130 Mo installée), paquets PHP/Node récents, processus de build reproductible et scriptable. Alternative écartée : Debian (plus lourde, mais conservée comme plan B musl, voir D006). |
| D002 | 2026-10-15 | Architecture  | **x86_64 uniquement**. | Cible : développeurs sur machines réelles Intel/AMD + hyperviseurs. Pas de demande ARM64 identifiée. |
| D003 | 2026-10-15 | Boot         | **UEFI** (boot x86_64 legacy non supporté). | Matériel moderne ; simplifie les tests QEMU/OVMF ; VirtualBox/VMware gèrent UEFI nativement. |
| D004 | 2026-10-15 | Noyau        | Noyau **linux LTS de kernel.org** compilé par nos scripts, pas le paquet `linux-lts` Alpine. | Contrôle complet de la config (conteneurs, KVM, overlayfs, sécurité) exigé en P1 ; `check-config.sh` de Moby comme garde-fou. |
| D005 | 2026-10-15 | Scripts      | Scripts **bash strict** (`set -euo pipefail`), validés par `shellcheck`. | Fiabilité des scripts d'infra ; CI refuse tout script non conforme. |
| D006 | 2026-10-15 | Libc         | **musl** (défaut Alpine). Risque documenté : certains binaires précompilés (VSCodium) exigent glibc. Décision finale reportée en P5 — bascule Debian/glibc si nécessaire. | On tente d'abord la voie musl légère ; le plan B est tracé dès maintenant. |
| D007 | 2026-10-15 | CI           | **GitHub Actions** : job `lint` (shellcheck) + job `build` (make build) + job `test` (make test). | Standard, gratuit pour projets publics, runners Ubuntu avec shellcheck préinstallé. |
| D008 | 2026-10-15 | Gestion PHP  | Versions de PHP fournies par **les dépôts Alpine** avec sélection par `phpforge` (P6) ; pas de compilation source par défaut. | Reproductibilité et maintenance ; Alpine maintient plusieurs versions PHP en parallèle. |
