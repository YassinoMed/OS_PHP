# PROGRESS.md — Avancement PHPForge OS

Règles :

- Une seule tâche par itération : **la première case non cochée** ci-dessous.
- Une case n'est cochée qu'avec preuve (commande exécutée + sortie réelle),
  consignée dans le journal.
- Toute modification de DECISIONS.md est justifiée dans le journal.
- Si une tâche échoue 2 fois, elle est découpée en sous-tâches ici.

## Phases

- [x] P0 Dépôt : arborescence, Makefile, CI (shellcheck + build), README
- [ ] P1 Noyau : x86_64-desktop.config (UEFI, NVMe/SATA, ext4, overlayfs,
      conteneurs complets pour Docker, KVM, sécurité), build-kernel.sh,
      validation avec check-config.sh de Moby
- [ ] P2 Console : image Alpine bootable (mkimage), SSH, réseau, utilisateurs,
      boot QEMU UEFI automatisé
- [ ] P3 PHP : PHP-CLI/FPM, Composer, Nginx, SQLite, Git, tests de
      fumée (php -v, composer, page servie par Nginx)
- [ ] P4 Laravel : extensions PHP, Node, MariaDB, PostgreSQL, Redis, Mailpit ;
      test : laravel new + migrate + serve
- [ ] P5 Bureau : Xfce, terminal, navigateur, VSCodium, test de compatibilité
      musl (sinon décision Debian/glibc dans DECISIONS.md)
- [ ] P6 PHPForge Manager : outil (installer/changer de version PHP, gérer
      services et vhosts) + tests
- [ ] P7 Installateur et branding
- [ ] P8 Compatibilité : QEMU, VirtualBox, VMware, matériel réel Intel/AMD
- [ ] P9 (optionnel) Variante Buildroot pour appliance PHP

## Journal

_(Le journal est alimenté à chaque clôture d'itération : date, tâche,
résultat avec preuves, prochain risque.)_

### 2026-10-15 — P0 Dépôt : arborescence, Makefile, CI (shellcheck + build), README

- **Tâche** : initialiser le dépôt complet de la phase P0.
- **Résultat** : OK.
- **Travail réalisé** :
  - Arborescence complète P0 : `kernel/ console/ php/ laravel/ desktop/
    manager/ installer/ compat/ buildroot/ config/{kernel,alpine,php,manager}/
    docs/ scripts/ tests/`, `VERSION` (0.1.0), `LICENSE` (MIT), `README.md`,
    `docs/ARCHITECTURE.md`.
  - Pipeline unique `make lint|check|build|test|clean` : `scripts/lint.sh`
    (shellcheck sur tous les .sh), `scripts/check-tree.sh` (arborescence
    requise), `scripts/check-environment.sh` (outils par phase, WARN pour
    P1+), `scripts/build.sh` (manifeste SHA-256 `build/manifest.txt`),
    `tests/test_p0.sh` (7 tests).
  - CI GitHub Actions `.github/workflows/ci.yml` : un job `make lint` +
    `make build` + `make test` + upload de `build/manifest.txt`.
  - Création de `DECISIONS.md` (ADR D001–D005), justifiée ici : D001 socle
    Alpine/musl (repli Debian/glibc conditionnel au test P5) ; D002 noyau
    upstream longterm + config x86_64-desktop validée par check-config.sh de
    Moby ; D003 amorçage UEFI uniquement ; D004 CI GitHub Actions avec
    shellcheck bloquant ; D005 versionnage semver et nommage des artefacts
    `phpforge-<X.Y.Z>-<arch>`.
  - Consolidation : deux implémentations P0 parallèles coexistaient dans
    l'arbre ; fusion sur la structure granulaire (`scripts/*.sh`), suppression
    des doublons (`ci/local.sh`, `scripts/validate-tree.sh`, `scripts/lib/`),
    correction SC2295 dans `scripts/build.sh`.
- **Preuves** (commandes exécutées, sorties réelles) :
  - `make lint` → `shellcheck : 5 script(s) analysé(s), 0 échec(s).`
  - `make check` → `Arborescence conforme.` + `Environnement OK pour la phase
    courante (P0).` (3 outils P0 OK ; QEMU/wget en WARN P2, normal à ce stade)
  - `make build` → `Manifeste généré : …/build/manifest.txt (19 lignes).` +
    `BUILD P0 RÉUSSI.`
  - `make test` → `TOUS LES TESTS P0 SONT PASSÉS.` (T1 à T7 PASS)
- **Prochain risque** : Docker CLI présent mais daemon arrêté sur l'hôte de
  dev (`docker info` → KO) ; la P1 exigera un daemon Linux x86_64 actif pour
  compiler le noyau et exécuter check-config.sh de Moby — à trancher avec
  une décision D00x (build en conteneur) au début de la P1.
