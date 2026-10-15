# DECISIONS.md — Registre des décisions d'architecture (ADR) de PHPForge OS

Règles de gestion de ce fichier :

- Toute décision d'architecture est enregistrée ici, datée et motivée.
- Une entrée n'est jamais modifiée après coup : toute révision crée une
  nouvelle entrée qui référence et remplace l'ancienne.
- Ce fichier ne peut être modifié qu'avec une justification consignée dans
  le journal de PROGRESS.md.

---

## D001 — Socle utilisateur : Alpine Linux (musl)

- **Date** : 2026-10-15
- **Décision** : la distribution est construite sur Alpine Linux (libc musl,
  apk, OpenRC), via l'outil officiel `mkimage` pour générer le rootfs.
- **Motif** : légèreté (image minimale < 200 Mo), gestionnaire de paquets
  rapide, outillage officiel de création d'images, base idéale pour une
  console de développement.
- **Risque connu** : compatibilité musl des outils bureautiques (VSCodium
  notamment). Point de contrôle obligatoire en **P5** : si le test de
  compatibilité musl échoue, un repli vers Debian/glibc sera décidé ici.
- **Statut** : active (conditionnelle au test P5).

## D002 — Noyau : Linux upstream longterm, configuration dédiée x86_64-desktop

- **Date** : 2026-10-15
- **Décision** : le noyau est compilé depuis les sources upstream
  (kernel.org, branche longterm la plus récente au moment de P1), avec une
  configuration maison `kernel/configs/x86_64-desktop.config` couvrant :
  UEFI, NVMe/SATA, ext4, overlayfs, conteneurs complets (namespaces, cgroups
  v2 — requis Docker), KVM, options de sécurité (hardening).
- **Motif** : maîtrise totale de la configuration, image noyau minimale et
  adaptée aux cibles (QEMU, VirtualBox, VMware, matériel Intel/AMD).
- **Validation** : `check-config.sh` du projet Moby doit passer (requis
  pour Docker). La version exacte du noyau sera épinglée en P1 dans
  `kernel/versions.mk`.
- **Statut** : active.

## D003 — Amorçage : UEFI uniquement

- **Date** : 2026-10-15
- **Décision** : seul l'amorçage UEFI est supporté (pas de BIOS legacy).
- **Motif** : toutes les cibles visées (QEMU/OVMF, VirtualBox, VMware,
  matériel Intel/AMD récent) supportent UEFI ; cela simplifie le chargeur
  d'amorçage, l'installateur et les tests.
- **Statut** : active.

## D004 — CI : GitHub Actions, shellcheck bloquant

- **Date** : 2026-10-15
- **Décision** : l'intégration continue tourne sur GitHub Actions
  (`.github/workflows/ci.yml`). Tout script shell du dépôt doit passer
  `shellcheck` sans erreur ; un échec bloque la fusion. Un job « build »
  valide l'intégrité du dépôt et, à partir de P1, construira les artefacts
  (noyau, image).
- **Motif** : reproductibilité, qualité constante des scripts de build.
- **Statut** : active.

## D005 — Versionnage et nommage des artefacts

- **Date** : 2026-10-15
- **Décision** : versions sémantiques `X.Y.Z`, tags git `vX.Y.Z`, artefacts
  nommés `phpforge-<X.Y.Z>-<arch>.img` (image disque) et
  `phpforge-<X.Y.Z>-<arch>.iso` (installateur, à partir de P7).
- **Motif** : traçabilité entre tags git, artefacts publiés et rapports
  de test.
- **Statut** : active.
