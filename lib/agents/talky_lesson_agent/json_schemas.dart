Map<String, dynamic> completeLessonToolSchema = {
  "properties": {
    "success": {
      "default":
          "Student has completed the lesson successfully. Unsuccessful if user did not follow the conversation, could not properly express himself",
      "title": "Success",
      "type": "boolean"
    },
    "remarks": {
      "default": "Remarks in a form of bullet points",
      "items": {"type": "string"},
      "title": "Remarks",
      "type": "array"
    },
    "feedback": {
      "default": "Short feedback on the lesson",
      "title": "Feedback",
      "type": "string"
    }
  },
  "title": "CompleteLessonResponse",
  "type": "object"
};
