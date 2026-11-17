FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90 AS dependencias

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/instalado -r requirements.txt


FROM python:3.13-slim@sha256:e48f59cdba69a3cbd9ed2cf0f348d90d45a8d350d98134cf1070bc106ee9ed90

# A base muda mais devagar que os CVEs: sem o upgrade o scan da imagem reprova.
RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# O pip e o setuptools carregam cópias de bibliotecas (urllib3, msgpack) com CVE
# e não fazem falta em runtime: as dependências já vieram do estágio anterior.
RUN python -m pip uninstall -y pip setuptools wheel 2>/dev/null || true

# Usuário sem privilégio: o Trivy reprova Dockerfile sem USER.
RUN useradd --system --uid 10001 --no-create-home app

WORKDIR /app
COPY --from=dependencias /instalado /usr/local
COPY app ./app

USER app
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request as u; u.urlopen('http://127.0.0.1:8000/saude')"
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
