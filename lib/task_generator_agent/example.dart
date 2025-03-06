import 'task_generator_agent.dart';
import 'dart:io';

final planSnippet = {
  "Goal 1": {
    "summary":
        "Learn the basics of the English language, including alphabet, sounds, and common phrases.",
    "subgoals": {
      "Subgoal 1.1": {
        "Lesson 1.1.1": {"name": "English Alphabet", "complete": true},
        "Lesson 1.1.2": {"name": "Consonants", "complete": true}
      },
      "Subgoal 1.2": {
        "Lesson 1.2.1": {"name": "Vowels", "complete": false},
        "Lesson 1.2.2": {"name": "Monophthongs", "complete": false}
      },
      "Subgoal 1.3": {
        "Lesson 1.3.1": {"name": "Diphthongs", "complete": false},
        "Lesson 1.3.2": {"name": "Common Greetings", "complete": false}
      }
    }
  }
};

void main() async {
  TaskGeneratorAgent agent = TaskGeneratorAgent(planSnippet: planSnippet);
  String systemPrompt = await agent.generateSystemPrompt(planSnippet);
  print(systemPrompt);
}
