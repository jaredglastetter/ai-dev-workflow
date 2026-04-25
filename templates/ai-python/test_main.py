from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_agent_echo():
    response = client.post("/agent", json={"prompt": "hello"})
    assert response.status_code == 200
    assert "Echo: hello" in response.json()["response"]
