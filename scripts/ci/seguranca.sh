#!/usr/bin/env bash
# Verificações de segurança do pipeline. Uso: seguranca.sh segredos|dependencias|sast|imagem <tag>
# Versões fixas e binários conferidos por SHA-256 (o checksum vem do arquivo oficial de cada release).
set -euo pipefail

GITLEAKS_VERSION="8.30.1"
GITLEAKS_SHA256="551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb"
TRIVY_VERSION="0.76.2"
TRIVY_SHA256="bc0fc726e017b8927a62b2d3531d7a84ee01769daf5c99ed866dced54089fdbf"
SEMGREP_VERSION="1.185.0"

BIN="${HOME}/.cache/pipeline-bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

# baixa o tar.gz, confere o SHA-256 e extrai só o binário pedido
instalar() {
  local nome="$1" url="$2" sha="$3"
  command -v "$nome" >/dev/null 2>&1 && return 0
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL --retry 3 -o "$tmp/pacote.tar.gz" "$url"
  echo "${sha}  $tmp/pacote.tar.gz" | sha256sum -c - >/dev/null
  tar -xzf "$tmp/pacote.tar.gz" -C "$tmp" "$nome"
  install -m 0755 "$tmp/$nome" "$BIN/$nome"
  rm -rf "$tmp"
}

case "${1:-}" in
  segredos)
    instalar gitleaks \
      "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
      "$GITLEAKS_SHA256"
    # lê o histórico inteiro: segredo apagado num commit antigo continua vazado
    gitleaks detect --source . --no-banner --redact --exit-code 1
    ;;
  dependencias)
    instalar trivy \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      "$TRIVY_SHA256"
    # vuln: CVEs das dependências · misconfig: Dockerfile sem USER e afins
    trivy fs --scanners vuln,misconfig --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 .
    ;;
  sast)
    pip install --quiet "semgrep==${SEMGREP_VERSION}"
    semgrep scan --config p/python --config p/dockerfile --error --metrics=off app Dockerfile
    ;;
  imagem)
    : "${2:?informe a tag da imagem}"
    instalar trivy \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
      "$TRIVY_SHA256"
    trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "$2"
    ;;
  *)
    echo "uso: $0 segredos|dependencias|sast|imagem <tag>" >&2
    exit 2
    ;;
esac
