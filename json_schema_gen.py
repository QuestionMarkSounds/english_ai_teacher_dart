from pydantic import BaseModel, TypeAdapter, Field
import json 
class Answer(BaseModel):
    exercise: str = Field("Generated exercise") 
    ideal_answer: str = Field("Generated ideal answer")

ta = TypeAdapter(Answer)
ta_schema = ta.json_schema()
print(json.dumps(ta_schema, indent=2))