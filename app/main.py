from fastapi import FastAPI

app = FastAPI(title="Exemplo do pipeline")


@app.get("/saude")
def saude() -> dict[str, str]:
    """Endpoint mínimo só para o pipeline ter o que buildar, testar e escanear."""
    return {"status": "ok"}
