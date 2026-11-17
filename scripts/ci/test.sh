#!/usr/bin/env bash
# Gancho de testes: cada repositório implementa o seu.
set -euo pipefail
cd "$(dirname "$0")/../.."
pip install --quiet -r requirements-dev.txt
pytest -q
