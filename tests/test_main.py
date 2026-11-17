from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_saude_responde_ok():
    resposta = client.get("/saude")
    assert resposta.status_code == 200
    assert resposta.json() == {"status": "ok"}


def test_rota_inexistente_da_404():
    assert client.get("/nao-existe").status_code == 404
