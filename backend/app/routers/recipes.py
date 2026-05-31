from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..models import Recipe, Ingredient, Step, Tag, Photo
from ..schemas import RecipeCreate, RecipeOut
from typing import List, Optional
from PIL import Image
import os
import shutil
import uuid

router = APIRouter()

PHOTOS_DIR = os.getenv("PHOTOS_DIR", "/app/photos")


@router.post("/", response_model=RecipeOut)
def create_recipe(recipe: RecipeCreate, db: Session = Depends(get_db)):
    new_recipe = Recipe(title=recipe.title, description=recipe.description)
    db.add(new_recipe)
    db.flush()

    for ing in recipe.ingredients:
        db.add(Ingredient(recipe_id=new_recipe.id, **ing.model_dump()))

    for step in recipe.steps:
        db.add(Step(recipe_id=new_recipe.id, **step.model_dump()))

    for tag_id in recipe.tag_ids:
        tag = db.query(Tag).filter(Tag.id == tag_id).first()
        if tag:
            new_recipe.tags.append(tag)

    db.commit()
    db.refresh(new_recipe)
    return _format_recipe(new_recipe)


@router.get("/", response_model=List[RecipeOut])
def list_recipes(
    tag: Optional[str] = Query(None),
    ingredient: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    query = db.query(Recipe)

    if tag:
        query = query.filter(Recipe.tags.any(Tag.name.ilike(f"%{tag}%")))

    if ingredient:
        query = query.filter(Recipe.ingredients.any(Ingredient.name.ilike(f"%{ingredient}%")))

    return [_format_recipe(r) for r in query.all()]


@router.get("/{recipe_id}", response_model=RecipeOut)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return _format_recipe(recipe)


@router.delete("/{recipe_id}")
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    db.delete(recipe)
    db.commit()
    return {"message": f"Recipe '{recipe.title}' deleted"}


@router.post("/{recipe_id}/photos")
def upload_photo(recipe_id: int, file: UploadFile = File(...), db: Session = Depends(get_db)):
    recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    ext = os.path.splitext(file.filename)[1].lower()
    if ext not in [".jpg", ".jpeg", ".png", ".webp"]:
        raise HTTPException(status_code=400, detail="Invalid image format")

    filename = f"{uuid.uuid4()}{ext}"
    filepath = os.path.join(PHOTOS_DIR, filename)

    with open(filepath, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image = Image.open(filepath)
    image.thumbnail((1024, 1024))
    image.save(filepath)

    db.add(Photo(recipe_id=recipe_id, file_path=filename))
    db.commit()

    return {"message": "Photo uploaded", "filename": filename}


def _format_recipe(recipe: Recipe) -> dict:
    return {
        "id": recipe.id,
        "title": recipe.title,
        "description": recipe.description,
        "created_at": recipe.created_at,
        "ingredients": recipe.ingredients,
        "steps": recipe.steps,
        "tags": recipe.tags,
        "photos": [p.file_path for p in recipe.photos],
    }
