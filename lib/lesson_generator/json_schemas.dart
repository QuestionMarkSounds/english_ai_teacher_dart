Map<String, dynamic> lessonGenSchema = {
  "\$defs": {
    "LessonSchema": {
      "properties": {
        "name": {
          "default": "Short lesson name",
          "title": "Name",
          "type": "string"
        },
        "system_prompt": {
          "default": "AI tutor instructions to facilitate the lesson",
          "title": "System Prompt",
          "type": "string"
        },
        "duration": {
          "default": "Duration of the lesson in minutes. Max 15 minutes.",
          "title": "Duration",
          "type": "integer"
        }
      },
      "title": "LessonSchema",
      "type": "object"
    }
  },
  "properties": {
    "lessons": {
      "items": {"\$ref": "#/\$defs/LessonSchema"},
      "title": "Lessons",
      "type": "array"
    }
  },
  "required": ["lessons"],
  "title": "Lessons",
  "type": "object"
};
