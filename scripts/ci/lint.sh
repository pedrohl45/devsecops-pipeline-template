#!/usr/bin/env bash
# Gancho de lint: cada repositório implementa o seu. Aqui: ruff (regras de segurança incluídas).
set -euo pipefail
cd "$(dirname "$0")/../.."
pip install --quiet -r requirements-dev.txt
ruff check .
ruff format --check .
