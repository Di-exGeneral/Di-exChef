# Di-exChef - Let's Cook
A personal recipe manager built as a daily-use utility and a hands-on DevOps learning project. This is for people who often forget their own recipes

## What it does

Di-exChef lets you store, organise, and search your personal recipe collection. You can tag recipes, search by ingredient, and attach photos — all through a clean REST API that will power a Flutter mobile frontend.

## Tech stack

| Layer | Technology |
|---|---|
| API | FastAPI (Python) |
| Database | PostgreSQL 15 |
| ORM | SQLAlchemy |
| Validation | Pydantic |
| Containerisation | Docker + Docker Compose |
| Image handling | Pillow |

## Project structure

```
Di-exChef/
├── backend/
│   ├── app/
│   │   ├── main.py          # Entry point, router registration
│   │   ├── database.py      # Database connection and session management
│   │   ├── models.py        # SQLAlchemy table definitions
│   │   ├── schemas.py       # Pydantic request/response schemas
│   │   └── routers/
│   │       ├── recipes.py   # Recipe CRUD and photo upload
│   │       └── tags.py      # Tag CRUD
│   ├── Dockerfile
│   └── requirements.txt
├── compose.yml
└── .gitignore
```

## Getting started

### Prerequisites

- Docker
- Docker Compose

### Setup

1. Clone the repository

```bash
git clone https://github.com/Di-exGeneral/Di-exChef.git
cd Di-exChef
```

2. Create your environment file

```bash
cp backend/.env.example backend/.env
```

Edit `backend/.env` with your own values:

```
DATABASE_URL=postgresql://your_user:your_password@db:5432/your_db
POSTGRES_USER=your_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=your_db
PHOTOS_DIR=/app/photos
```

3. Build and run

```bash
docker compose -f compose.yml up --build
```

4. Visit the interactive API docs

```
http://localhost:8000/docs
```

## API endpoints

### Recipes

| Method | Endpoint | Description |
|---|---|---|
| POST | `/recipes/` | Create a new recipe |
| GET | `/recipes/` | List all recipes |
| GET | `/recipes/?ingredient=eggs` | Search by ingredient |
| GET | `/recipes/?tag=breakfast` | Filter by tag |
| GET | `/recipes/{id}` | Get a single recipe |
| DELETE | `/recipes/{id}` | Delete a recipe |
| POST | `/recipes/{id}/photos` | Upload a photo |

### Tags

| Method | Endpoint | Description |
|---|---|---|
| POST | `/tags/` | Create a tag |
| GET | `/tags/` | List all tags |
| DELETE | `/tags/{id}` | Delete a tag |

## DevOps concepts practised

- Writing production-grade Dockerfiles with layer caching
- Multi-service orchestration with Docker Compose
- Health checks and service dependency ordering
- Volume management for persistent data
- Environment variable management with `.env` files
- GitHub Actions CI (coming in Phase 3)
- AWS EC2 deployment (coming in Phase 4)

## Roadmap

- [x] Phase 1 — Backend API with Docker
- [ ] Phase 2 — Flutter mobile frontend
- [ ] Phase 3 — GitHub Actions CI pipeline
- [ ] Phase 4 — AWS EC2 deployment with Nginx

## Author

Built by Tlotliso Ledwaba ([Di-exGeneral](https://github.com/Di-exGeneral)) as part of a structured DevOps engineering roadmap.
