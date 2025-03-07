Map<String, dynamic> lessonGenSchema = {
  "\$defs": {
    "LessonSchema": {
      "properties": {
        "name": {
          "default": "Title of the lesson",
          "title": "Name",
          "type": "string"
        },
        "description": {
          "default":
              "Brief description of the lesson in a form of imperative sentence. Do not mention the user information. Do not use the user description. Max 1 sentence",
          "type": "string"
        },
        "duration": {
          "default": "Duration of the lesson in minutes. Max 15 minutes",
          "title": "Duration",
          "type": "integer"
        },
        "complexity": {
          "default":
              "Complexity level of the lesson. From 1 to 5, with 5 being the most complex",
          "title": "Complexity",
          "type": "integer"
        },
        "system_prompt": {
          "default": "AI tutor instructions to facilitate the lesson",
          "title": "System Prompt",
          "type": "string"
        }
      },
      "title": "LessonSchema",
      "type": "object"
    }
  },
  "properties": {
    "lessons": {
      "description": "List of lesson objects",
      "items": {"\$ref": "#/\$defs/LessonSchema"},
      "title": "Lessons",
      "type": "array"
    }
  },
  "required": ["lessons"],
  "title": "Lessons",
  "type": "object"
};
