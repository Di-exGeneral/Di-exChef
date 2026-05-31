import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.database import Base, get_db

SQLALCHEMY_TEST_URL = "sqlite:///./test.db"

engine = create_engine(
    SQLALCHEMY_TEST_URL,
    connect_args={"check_same_thread": False}
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db
client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"message": "Di-exChef API is running"}


def test_create_tag():
    response = client.post("/tags/", json={"name": "test-tag"})
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "test-tag"
    assert "id" in data


def test_duplicate_tag():
    client.post("/tags/", json={"name": "duplicate-tag"})
    response = client.post("/tags/", json={"name": "duplicate-tag"})
    assert response.status_code == 400


def test_list_tags():
    response = client.get("/tags/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_create_recipe():
    response = client.post("/recipes/", json={
        "title": "Test Recipe",
        "description": "A test recipe",
        "ingredients": [
            {"name": "eggs", "quantity": "2", "unit": "whole"}
        ],
        "steps": [
            {"order_number": 1, "instruction": "Crack the eggs"}
        ],
        "tag_ids": []
    })
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Recipe"
    assert len(data["ingredients"]) == 1
    assert len(data["steps"]) == 1


def test_list_recipes():
    response = client.get("/recipes/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_get_recipe():
    create = client.post("/recipes/", json={
        "title": "Get Test",
        "description": "",
        "ingredients": [],
        "steps": [],
        "tag_ids": []
    })
    recipe_id = create.json()["id"]
    response = client.get(f"/recipes/{recipe_id}")
    assert response.status_code == 200
    assert response.json()["id"] == recipe_id


def test_delete_recipe():
    create = client.post("/recipes/", json={
        "title": "Delete Test",
        "description": "",
        "ingredients": [],
        "steps": [],
        "tag_ids": []
    })
    recipe_id = create.json()["id"]
    response = client.delete(f"/recipes/{recipe_id}")
    assert response.status_code == 200
    gone = client.get(f"/recipes/{recipe_id}")
    assert gone.status_code == 404


def test_recipe_not_found():
    response = client.get("/recipes/99999")
    assert response.status_code == 404