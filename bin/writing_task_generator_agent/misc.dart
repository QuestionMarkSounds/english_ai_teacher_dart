Map<String, dynamic> systemPrompts = {
  "Creative Story Prompts": {
    "howItWorks":
        "The app displays an open-ended prompt (e.g., 'On a rainy night, a mysterious knock interrupts your routine…').",
    "objective":
        "Encourage users to craft their own narrative focusing on plot development, setting, and character creation.",
    "variations":
        "Rotate prompts by genre (mystery, fantasy, adventure) to challenge different writing styles.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default": "Generated exercise main instruction sentence.",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "exercise_lead": {
          "default": "Generated exercise leads and helpers",
          "title": "Exercise Lead",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "Answer",
      "type": "object"
    }
  },
  "Picture-Based Descriptive Writing": {
    "howItWorks":
        "Show a vivid image (landscape, urban scene, or abstract art) and ask the learner to write a descriptive paragraph or short story based on what they see.",
    "objective":
        "Enhance observational skills and descriptive language through sensory details such as sight, sound, and smell."
  },
  "Dialogue Generation": {
    "howItWorks":
        "Present a scenario with a conversation starter or an incomplete dialogue between two characters, prompting the learner to fill in the gaps.",
    "objective":
        "Practice natural conversational English, idiomatic expressions, and proper dialogue formatting.",
    "jsonSchema": {
      "\$defs": {
        "DialogueMessage": {
          "properties": {
            "role": {
              "default": "Role of the character",
              "enum": ["A", "B"],
              "title": "Role",
              "type": "string"
            },
            "name": {
              "default": "Name of the character",
              "title": "Name",
              "type": "string"
            },
            "message": {
              "default": "Message of the character",
              "title": "Message",
              "type": "string"
            }
          },
          "title": "DialogueMessage",
          "type": "object"
        }
      },
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default": "Generated exercise main instruction sentence.",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_dialogue": {
          "default": "Incomplete dialogue",
          "items": {"\$ref": "#/\$defs/DialogueMessage"},
          "title": "Exercise Dialogue",
          "type": "array"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "DialogueGeneration",
      "type": "object"
    }
  },
  "Sentence Expansion": {
    "howItWorks":
        "Provide a simple sentence (e.g., 'The dog barked.') and ask the learner to expand it into a complex sentence or a short paragraph by adding adjectives, adverbs, subordinate clauses, and additional details.",
    "objective":
        "Improve sentence structure and complexity while enriching vocabulary.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default": "Generated exercise main instruction sentence.",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "sentence_to_expand": {
          "default": "Generated exercise sentence to expand",
          "title": "Sentence To Expand",
          "type": "string"
        },
        "what_to_expand": {
          "default": "Instructions on what to expand in the sentence",
          "title": "What To Expand",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "SentenceExpansion",
      "type": "object"
    }
  },
  "Story Chain Writing": {
    "howItWorks":
        "Start with an opening sentence or paragraph, then have the learner add the next part. Optionally, alternate with app-generated segments to build a continuous narrative.",
    "objective":
        "Foster narrative coherence, creativity, and logical progression in storytelling.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default":
              "Generated exercise main instruction sentence for the user.",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction for the user",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "sentence_to_start_with": {
          "default": "Sentence or sentences to start with",
          "title": "Sentence To Start With",
          "type": "string"
        },
        "ideas_on_how_to_continue": {
          "default": "Suggestions on how to continue the story",
          "title": "Ideas On How To Continue",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "StoryChainWriting",
      "type": "object"
    }
  },
  "Role-Play Scenario Writing": {
    "howItWorks":
        "Describe a real-life scenario (e.g., ordering food in a restaurant or checking into a hotel) and prompt the learner to write a dialogue or monologue suited to that context.",
    "objective":
        "Develop practical language usage, appropriate tone, and situational vocabulary.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default":
              "Generated exercise main instruction sentence for the user",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction for the user",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "roleplay_setting": {
          "default": "Initial setting for the roleplay",
          "title": "Roleplay Setting",
          "type": "string"
        },
        "ideas": {
          "default": "Ideas and Suggestions on how to complete the exercise",
          "title": "Ideas",
          "type": "string"
        },
        "roles": {
          "default": "List of roles in the roleplay",
          "items": {"type": "string"},
          "title": "Roles",
          "type": "array"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "RolePlayScenarioWriting",
      "type": "object"
    }
  },
  "Email/Letter Composition": {
    "howItWorks":
        "Provide a context for formal or informal communication (e.g., writing a complaint, sending an invitation, or thanking someone) and ask the learner to compose an email or letter.",
    "objective":
        "Teach structure, tone, and format appropriate for different types of correspondence.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default":
              "Generated exercise main instruction sentence for the user",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction for the user",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "ideas": {
          "default": "Ideas and Suggestions on how to complete the exercise",
          "title": "Ideas",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "EmailLetterComposition",
      "type": "object"
    }
  },
  "Genre Switching Exercise": {
    "howItWorks":
        "Offer a piece of text (or a basic narrative) and ask the learner to rewrite it in a different genre or style (e.g., from a factual description to a fairy tale, from a thriller to a romantic novel, from a science fiction to a historical novel or vice versa).",
    "objective":
        "Encourage flexibility in writing style and creative adaptation of content.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "text_to_rewrite": {
          "default": "Text to rewrite in a different genre",
          "title": "Text To Rewrite",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default":
              "Generated exercise main instruction sentence for the user",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction for the user",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "ideas": {
          "default": "Ideas and Suggestions on how to complete the exercise",
          "title": "Ideas",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "GenreSwitchingExercise",
      "type": "object"
    }
  },
  "Paraphrasing and Summarization": {
    "howItWorks":
        "Present a short passage and require the learner to paraphrase it or summarize its main points in their own words.",
    "objective":
        "Reinforce comprehension and the ability to convey information concisely while practicing vocabulary and syntax.",
    "jsonSchema": {
      "properties": {
        "task_name": {
          "default": "Generated exercise name",
          "title": "Task Name",
          "type": "string"
        },
        "passage": {
          "default": "Passage to paraphrase and/or summarize",
          "title": "Passage",
          "type": "string"
        },
        "exercise_main_instruction": {
          "default":
              "Generated exercise main instruction sentence for the user",
          "title": "Exercise Main Instruction",
          "type": "string"
        },
        "exercise_sub_instruction": {
          "default": "Generated exercise sub instruction for the user",
          "title": "Exercise Sub Instruction",
          "type": "string"
        },
        "ideal_answer": {
          "default": "Generated ideal answer",
          "title": "Ideal Answer",
          "type": "string"
        }
      },
      "title": "ParaphrasingAndSummarization",
      "type": "object"
    }
  },
  "Character Creation and Profiles": {
    "howItWorks":
        "Provide a set of character traits (name, age, occupation, personality) and ask learners to create a detailed profile that can serve as a foundation for a narrative exercise.",
    "objective":
        "Build skills in developing believable characters and linking character details to plot."
  },
  "Word Association Story": {
    "howItWorks":
        "Display one or more random words and challenge the learner to write a short story or series of sentences that naturally incorporate these words.",
    "objective": "Stimulate creative thinking and associative vocabulary usage."
  },
  "Perspective Shift Writing": {
    "howItWorks":
        "Ask learners to retell a familiar story or describe a scene from a different perspective (e.g., from the point of view of a secondary character or an inanimate object).",
    "objective":
        "Encourage creative thinking, empathy, and an understanding of narrative voice."
  }
};

List<String> englishLevels = ["A1", "A2", "B1", "B2", "C1", "C2"];
