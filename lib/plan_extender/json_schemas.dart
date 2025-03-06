// String timeFormatPrompt = " Formated as Y-M-W-D where Y is number of years, M is number of outstanding months, W is number of outstanding weeks and D is number of outstanding days.";
String timeFormatPrompt =
    """Formatted as an integer and a character corresponding to duration (2D, 3W, 2M, 1Y). For example: 2D - 2 days. 3W - 3 weeks. 2M - 2 months. 1Y - 1 year.""";

Map<String, dynamic> extendPlanSchema = {
  "\$defs": {
    "Goal": {
      "properties": {
        "reasoning": {
          "description": "The reasoning behind the goal.",
          "title": "Reasoning",
          "type": "string"
        },
        "name": {
          "description":
              "The name of the goal. Just the name, without 'Goal #: '.",
          "title": "Name",
          "type": "string"
        },
        "duration": {
          "description": "The duration of the goal.",
          "title": "Duration of the goal. $timeFormatPrompt",
          "type": "string"
        },
        "subgoals": {
          "description": "The high level subgoals of the goal. Exactly 4.",
          "items": {"\$ref": "#/\$defs/Subgoal"},
          "title": "Subgoals",
          "type": "array"
        }
      },
      "required": ["reasoning", "name", "duration", "subgoals"],
      "title": "Goal",
      "type": "object"
    },
    "Subgoal": {
      "properties": {
        "reasoning": {
          "description": "The reasoning behind the subgoal.",
          "title": "Reasoning",
          "type": "string"
        },
        "name": {
          "description":
              "The name of the subgoal. Just the name, without 'Subgoal #: '.",
          "title": "Name",
          "type": "string"
        },
        "duration": {
          "description": "The duration of the subgoal.",
          "title": "Duration of the subgoal. $timeFormatPrompt",
          "type": "string"
        },
        "lessons": {
          "description": "An empty placeholder for lessons.",
          "items": {"type": "string"},
          "title": "Lessons",
          "type": "array"
        }
      },
      "required": ["reasoning", "name", "duration", "lessons"],
      "title": "Subgoal",
      "type": "object"
    }
  },
  "properties": {
    "reasoning": {
      "description": "The reasoning behind the learning plan.",
      "title": "Reasoning",
      "type": "string"
    },
    "name": {
      "description": "The name of the learning plan.",
      "title": "Name",
      "type": "string"
    },
    "duration": {
      "description": "The duration of the learning plan.",
      "title": "Duration of the learning plan. $timeFormatPrompt",
      "type": "string"
    },
    "goals": {
      "description": "The high level goals of the learning plan. Exactly 3.",
      "items": {"\$ref": "#/\$defs/Goal"},
      "title": "Goals",
      "type": "array"
    }
  },
  "required": ["reasoning", "name", "duration", "goals"],
  "title": "Plan",
  "type": "object"
};
