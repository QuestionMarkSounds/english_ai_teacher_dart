from pydantic import BaseModel, TypeAdapter, Field
import json 
from typing import Literal, List

class Goal(BaseModel):
    summary: str = Field(..., title="Generated exercise name")

class LearningPlan(BaseModel):
    plan: list[Goal] = Field(..., title="Generated exercise name")



class DialogueMessage(BaseModel):
    role: Literal["A", "B"] = Field("Role of the character")
    name: str = Field("Name of the character")
    message: str = Field("Message of the character")

class DialogueGeneration(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence.")
    exercise_dialogue: List[DialogueMessage] = Field("Incomplete dialogue") 
    ideal_answer: str = Field("Generated ideal answer")

class CreativeStoryPrompts(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence.")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction") 
    exercise_lead: str = Field("Generated exercise leads and helpers") 
    ideal_answer: str = Field("Generated ideal answer")

class SentenceExpansion(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence.")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction") 
    sentence_to_expand: str = Field("Generated exercise sentence to expand") 
    what_to_expand: str = Field("Instructions on what to expand in the sentence")
    ideal_answer: str = Field("Generated ideal answer")

class StoryChainWriting(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence for the user")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction for the user") 
    sentence_to_start_with: str = Field("Sentence or sentences to start with") 
    ideas_on_how_to_continue: str = Field("Suggestions on how to continue the story")
    ideal_answer: str = Field("Generated ideal answer")

class RolePlayScenarioWriting(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence for the user")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction for the user") 
    roleplay_setting: str = Field("Initial setting for the roleplay")
    ideas: str = Field("Ideas and Suggestions on how to complete the exercise")
    roles: List[str] = Field("List of roles in the roleplay")
    ideal_answer: str = Field("Generated ideal answer")

class EmailLetterComposition(BaseModel):
    task_name: str = Field("Generated exercise name")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence for the user")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction for the user") 
    ideas: str = Field("Ideas and Suggestions on how to complete the exercise")
    ideal_answer: str = Field("Generated ideal answer")

class GenreSwitchingExercise(BaseModel):
    task_name: str = Field("Generated exercise name")
    text_to_rewrite: str = Field("Text to rewrite in a different genre")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence for the user")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction for the user") 
    ideas: str = Field("Ideas and Suggestions on how to complete the exercise")
    ideal_answer: str = Field("Generated ideal answer")

class ParaphrasingAndSummarization(BaseModel):
    task_name: str = Field("Generated exercise name")
    passage: str = Field("Passage to paraphrase and/or summarize")
    exercise_main_instruction: str = Field("Generated exercise main instruction sentence for the user")
    exercise_sub_instruction: str = Field("Generated exercise sub instruction for the user") 
    ideal_answer: str = Field("Generated ideal answer")

class TalkyAssesmentResponse(BaseModel):
    mistakes_present: bool = Field("True if mistakes are present, False if not")
    response: str = Field("Response to the prompt")
    number: int


class LessonSchema(BaseModel):
    name: str = Field("Title of the lesson")
    description: str = Field(
        default="This lesson will help improve specific language skills through engaging exercises.", 
        title="Description", 
        description="Brief description of the lesson's benefits. Max 2 sentences."
    )
    duration: int = Field("Duration of the lesson in minutes. Max 15 minutes")
    complexity: int = Field("Complexity level of the lesson. From 1 to 5, with 5 being the most complex")
    system_prompt: str = Field("AI tutor instructions to facilitate the lesson")
    


class Lessons(BaseModel):
    lessons: List[LessonSchema] = Field(title="Lessons", description="List of lesson objects")


ta = TypeAdapter(Lessons)
ta_schema = ta.json_schema()
print(json.dumps(ta_schema, indent=2))