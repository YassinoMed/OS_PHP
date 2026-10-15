# PROGRESS.md — Phases et journal des itérations

Règles : une seule tâche (case) par itération ; case cochée uniquement avec
preuve (commande + sortie) ; si 2 échecs → découper en sous-tâches.

## Phases

- [x] **P0 Dépôt** : arborescence, Makefile, CI (shellcheck + build), README
- [ ] **P1 Noyau** : `x86_64-desktop.config` (UEFI, NVMe/SATA, ext4, overlayfs,
      conteneurs complets pour Docker, KVM, sécurité), `build-kernel.sh`,
      validation avec `check-config.sh` de Moby
- [ ] **P2 Console** : image Alpine bootable (mkimage), SSH, réseau,
      utilisateurs, boot QEMU UEFI automatisé
- [ ] **P3 PHP** : PHP-CLI/FPM, Composer, Nginx, SQLite, Git, tests de fumée
      (`php -v`, `composer`, page servie par Nginx)
- [ ] **P4 Laravel** : extensions PHP, Node, MariaDB, PostgreSQL, Redis,
      Mailpit ; test : `laravel new` + `migrate` + `serve`
- [ ] **P5 Bureau** : Xfce, terminal, navigateur, VSCodium, test de
      compatibilité musl (sinon décision Debian/glibc dans DECISIONS.md)
- [ ] **P6 PHPForge Manager** : outil (installer/changer de version PHP,
      gérer services et vhosts) + tests
- [ ] **P7 Installateur et branding**
- [ ] **P8 Compatibilité** : QEMU, VirtualBox, VMware, matériel réel Intel/AMD
- [ ] **P9 (optionnel)** Variante Buildroot pour appliance PHP

## Journal

| Date | Tâche | Résultat | Preuve | Prochain risque |
|------|-------|----------|--------|-----------------|
| 2026-10-15 | P0 Dépôt : arborescence, Makefile, CI, README | OK — dépôt initialisé, 3 cibles make opérationnelles, workflow CI en place ; création de DECISIONS.md (D001–D005) justifiée ici : bash strict + shellcheck (D001), base Alpine/musl (D002), noyau mainline + check-config Moby (D003), builds lourds en conteneur Docker Linux x86_64 (D004), CI GH Actions miroir de `ci/local.sh` (D005) | `make lint` → `shellcheck 0.11.0, 3 scripts, 0 erreur` ; `make check` → `structure du dépôt valide` ; `make build` → `rapport écrit dans build/report.txt` (contenu vérifié) | Docker CLI présent mais daemon arrêté (`docker info` → KO) : la P1 exigera un daemon Linux x86_64 actif (D004) pour compiler le noyau et lancer check-config.sh |
