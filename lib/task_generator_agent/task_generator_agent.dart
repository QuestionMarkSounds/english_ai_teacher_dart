import 'package:langchain/langchain.dart';
import 'package:retry/retry.dart';

import '../src/globals.dart';
import '../src/helper.dart';

// ----------------------------
// ----------------------------

class TaskGeneratorAgent {
  final Map<String, dynamic> planSnippet;

  TaskGeneratorAgent({required this.planSnippet});

  Future<String> generateSystemPrompt(Map<String, dynamic> planProgress) async {
    final systemPrompt = ChatMessage.system('''
      You are an intelligent task generator. Your job is to generate a system prompt for a task agent based on the current progress of the learning plan. 

      The learning plan follows a structured hierarchy: 
      - A Goal contains multiple Subgoals.
      - Each Subgoal consists of multiple Lessons.
      - Each Lesson has a completion status (true/false).

      Based on the given plan progress:
      - Identify the next incomplete lesson.
      - Consider the overall progress so far.
      - Generate a motivating, context-aware system prompt for the task agent to assist the user in completing the next lesson.

      Example:
      Given this progress:
      {
        "Goal 1": {
          "summary": "Learn the basics of the English language, including alphabet, sounds, and common phrases.",
          "subgoals": {
            "Subgoal 1.1": {
              "Lesson 1.1.1": {"name": "English Alphabet", "complete": true},
              "Lesson 1.1.2": {"name": "Consonants", "complete": true}
            },
            "Subgoal 1.2": {
              "Lesson 1.2.1": {"name": "Vowels", "complete": false},
              "Lesson 1.2.2": {"name": "Monophthongs", "complete": false}
            }
          }
        }
      }

      The next lesson to complete is "Lesson 1.2.1: Vowels".

      Your generated system prompt should be:
      ---
      "You are a learning assistant helping a user progress through their English learning journey. The user has successfully completed the alphabet and consonants. The next lesson is 'Vowels'. Guide the user through learning about vowels, explaining their role in pronunciation, providing examples, and interactive exercises."
      ---

      Always ensure that the generated system prompt:
      - Acknowledges prior progress.
      - Clearly states the next lesson.
      - Provides relevant instructions for the task agent.

      Now, generate the system prompt for the next task.
      Current progress:
      $planSnippet
    ''');

    String response = '';

    final prompt = PromptValue.chat([systemPrompt]);
    final res = await chatModel.invoke(prompt);
    response = res.outputAsString;

    return response;
  }
}
