# PHPForge OS

Distribution Linux légère pour développeurs PHP/Laravel : noyau mainline
x86_64, base Alpine (musl), stack PHP/Composer/Nginx, outils Laravel,
bureau Xfce, et un gestionnaire intégré (`PHPForge Manager`).

## Démarrage rapide

```sh
make help    # liste des cibles
make lint    # shellcheck sur tous les scripts
make check   # lint + arborescence + outils requis par phase
make build   # build P0 : manifeste versionné (build/manifest.txt)
make test    # tests de la phase courante
make clean   # suppression des artefacts
```

Le même pipeline tourne en CI : `.github/workflows/ci.yml`.

## Arborescence

```
OS_PHP/
├── Makefile            Cibles principales (lint, check, build, test)
├── VERSION             Version courante (semver X.Y.Z)
├── kernel/             P1 — config et build du noyau (config/kernel/)
├── console/            P2 — image console Alpine bootable (config/alpine/)
├── php/                P3 — stack PHP (PHP-CLI/FPM, Composer, Nginx)
├── laravel/            P4 — outils Laravel (Node, MariaDB, PostgreSQL, Redis)
├── desktop/            P5 — bureau Xfce et applications
├── manager/            P6 — PHPForge Manager (config/manager/)
├── installer/          P7 — installateur et branding
├── compat/             P8 — matrices de compatibilité (QEMU, VirtualBox…)
├── buildroot/          P9 (optionnel) — variante appliance Buildroot
├── config/             Configurations versionnées (kernel, alpine, php, manager)
├── scripts/            Scripts du pipeline : lint.sh, check-tree.sh,
│                       check-environment.sh, build.sh
├── tests/              Tests par phase (test_p0.sh, …)
├── docs/               Documentation (ARCHITECTURE.md)
├── build/              Artefacts locaux (ignoré par git)
└── .github/workflows/  CI : lint + build + test
```

## Feuille de route

Voir `PROGRESS.md` (phases P0 → P9, une case cochée par itération avec
preuve) et `DECISIONS.md` (décisions structurantes justifiées).

## Licence

MIT — voir `LICENSE`.
