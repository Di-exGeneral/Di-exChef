from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class IngredientBase(BaseModel):
    name: str
    quantity: Optional[str] = None
    unit: Optional[str] = None

class IngredientCreate(IngredientBase):
    pass


class IngredientOut(IngredientBase):
    id: int

    class Config:
        from_attributes = True


class StepBase(BaseModel):
    order_number: int
    instruction: str


class StepCreate(StepBase):
    pass


class StepOut(StepBase):
    id: int

    class Config:
        from_attributes = True


class TagBase(BaseModel):
    name: str


class TagCreate(TagBase):
    pass


class TagOut(TagBase):
    id: int

    class Config:
        from_attributes = True


class RecipeBase(BaseModel):
    title: str
    description: Optional[str] = None


class RecipeCreate(RecipeBase):
    ingredients: List[IngredientCreate] = []
    steps: List[StepCreate] = []
    tag_ids: List[int] = []


class RecipeOut(RecipeBase):
    id: int
    created_at: datetime
    ingredients: List[IngredientOut] = []
    steps: List[StepOut] = []
    tags: List[TagOut] = []
    photos: List[str] = []

    class Config:
        from_attributes = True
