# PHPForge OS

**PHPForge OS** est une distribution Linux légère conçue pour les développeurs
PHP / Laravel. Elle vise un système bootable (UEFI, x86_64) contenant tout
l'outillage nécessaire pour développer, tester et servir des applications
PHP modernes — sans ballast inutile.

## Objectifs

| Objectif | Détail |
|----------|--------|
| Léger    | Base [Alpine Linux](https://alpinelinux.org/) construite avec `mkimage`, noyau Linux LTS compilé sur mesure |
| Complet  | PHP-CLI/FPM, Composer, Nginx, SQLite, MariaDB, PostgreSQL, Redis, Node, Git |
| Moderne  | Laravel installable et fonctionnel out-of-the-box (`laravel new` + `migrate`) |
| Outilé   | `phpforge` : gestionnaire intégré (versions de PHP, services, vhosts) |
| Portable | Testé sur QEMU, VirtualBox, VMware et matériel réel Intel/AMD |

## Arborescence du dépôt

```
OS_PHP/
├── DECISIONS.md          # Décisions d'architecture (à lire en premier)
├── PROGRESS.md           # Phases + journal des itérations
├── Makefile              # lint / build / test / clean
├── .github/workflows/    # CI : shellcheck + build + tests
├── scripts/              # Scripts shell du projet (shellcheck strict)
│   ├── check-environment.sh
│   └── build.sh
├── config/               # Configs : kernel, mkimage, paquets, services
│   ├── kernel/           #   P1 : config noyau + build-kernel.sh
│   ├── alpine/           #   P2 : profil mkimage (aports)
│   ├── php/              #   P3/P4 : PHP, Composer, Nginx, SGBD
│   └── manager/          #   P6 : phpforge manager
├── tests/                # Tests exécutables (make test)
├── docs/                 # Documentation
└── build/                # Sorties de build (ignoré par git)
```

## Prérequis

- `git`, `make`, `bash` (≥ 4 conseillé ; les scripts sont compatibles bash 3.2+)
- `shellcheck` (pour `make lint`)
- Les outils de build de chaque phase sont vérifiés par :

```sh
./scripts/check-environment.sh
```

## Utilisation

```sh
make help      # liste des cibles
make lint      # shellcheck sur tous les scripts
make build     # validation + génération de build/manifest.txt
make test      # suite de tests
make clean     # nettoie build/
```

## Développement itératif

Le projet avance par itérations : **une seule tâche de `PROGRESS.md` par
itération**, livrable complet, aucune case cochée sans preuve (commande
exécutée + sortie attendue). Voir `PROGRESS.md` pour le détail et le journal.

## Licence

Projet PFE — voir `LICENSE`.
