from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from .database import engine, Base
from .routers import recipes, tags
import os

app = FastAPI(
    title="Di-exChef API",
    description="Personal recipe manager backend",
    version="1.0.0",
)


@app.on_event("startup")
def startup():
    Base.metadata.create_all(bind=engine)
    os.makedirs(os.getenv("PHOTOS_DIR", "/app/photos"), exist_ok=True)
    app.mount("/photos", StaticFiles(directory=os.getenv("PHOTOS_DIR", "/app/photos")), name="photos")


app.include_router(recipes.router, prefix="/recipes", tags=["recipes"])
app.include_router(tags.router, prefix="/tags", tags=["tags"])


@app.get("/")
def root():
    return {"message": "Di-exChef API is running"}
