# Makefile — PHPForge OS
# Cibles principales du projet. Le pipeline complet est dans ci/local.sh.

SHELL := /bin/bash

.PHONY: help lint check build clean

help:
	@echo "PHPForge OS — cibles :"
	@echo "  make lint    shellcheck + bash -n sur tous les scripts"
	@echo "  make check   validation de la structure et de l'environnement"
	@echo "  make build   pipeline CI local complet (lint + check + rapport)"
	@echo "  make clean   suppression des artefacts locaux"

lint:
	./ci/local.sh lint

check:
	./ci/local.sh check

build:
	./ci/local.sh build

clean:
	rm -rf build/
