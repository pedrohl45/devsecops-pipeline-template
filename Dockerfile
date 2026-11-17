FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928 AS dependencias

WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/instalado -r requirements.txt


FROM python:3.15-slim@sha256:65a65fc7b30b06cb6df4930fd4650697cb23f4c2698ab81fc87e4b031bc36928

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
