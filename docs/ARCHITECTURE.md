# Architecture — PHPForge OS

PHPForge OS est construite en couches, chaque phase livrant une couche
testable indépendamment :

| Couche | Phase | Contenu |
|--------|-------|---------|
| Noyau | P1 | Linux mainline x86_64 (`config/kernel/x86_64-desktop.config`), options UEFI, NVMe/SATA, ext4, overlayfs, conteneurs, KVM, sécurité — validé par `check-config.sh` de Moby |
| Console | P2 | Image Alpine bootable (mkimage), SSH, réseau, utilisateurs, boot QEMU UEFI automatisé |
| PHP | P3 | PHP-CLI/FPM, Composer, Nginx, SQLite, Git + tests de fumée |
| Laravel | P4 | Extensions PHP, Node, MariaDB, PostgreSQL, Redis, Mailpit |
| Bureau | P5 | Xfce, terminal, navigateur, VSCodium — après preuve de compatibilité musl |
| Manager | P6 | PHPForge Manager (versions PHP, services, vhosts) |
| Installateur | P7 | Installateur et branding |

## Principes

1. **Un pipeline unique** : `make lint|check|build|test` en local
   (`ci/local.sh`), identique en CI (`.github/workflows/ci.yml`).
2. **Builds reproductibles** : noyau et images compilés dans des conteneurs
   Docker Linux x86_64 (décision D004), jamais nativement sur l'hôte.
3. **Preuve avant coche** : chaque phase coche une case de `PROGRESS.md`
   avec la commande exécutée et sa sortie réelle.
4. **Config déclarative** : les répertoires `config/` regroupent les
   configurations versionnées (kernel, alpine, php, manager).
