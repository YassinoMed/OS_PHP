# PHPForge OS — Makefile racine
# Pipeline unique : make lint|check|build|test, identique en local et en CI.
# Les cibles de construction des artefacts (noyau, image, ISO) sont ajoutées
# dans leurs phases respectives : voir PROGRESS.md.

.DEFAULT_GOAL := help

.PHONY: help lint check build test clean

help: ## Affiche cette aide
	@echo "PHPForge OS — cibles :"
	@echo "  make lint    shellcheck sur tous les scripts (scripts/lint.sh)"
	@echo "  make check   lint + arborescence + outils requis (check-tree.sh, check-environment.sh)"
	@echo "  make build   build P0 : environnement, arborescence, manifeste (scripts/build.sh)"
	@echo "  make test    tests de la phase P0 (tests/test_p0.sh)"
	@echo "  make clean   supprime le répertoire d'artefacts build/"

lint: ## Vérifie tous les scripts shell du dépôt avec shellcheck
	@scripts/lint.sh

check: lint ## Vérifie l'intégrité du dépôt (arborescence + outils requis)
	@scripts/check-tree.sh
	@scripts/check-environment.sh

build: check ## Build P0 : manifeste versionné du dépôt
	@scripts/build.sh --skip-env

test: ## Exécute les tests de la phase P0
	@tests/test_p0.sh

clean: ## Supprime le répertoire d'artefacts build/
	@rm -rf build
