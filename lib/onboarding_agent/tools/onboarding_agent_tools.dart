import 'dart:io';
import 'package:langchain/langchain.dart';
import 'dart:convert';

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

File learningPlanFile = File('learning_plan.json');

final class GeneratePlan
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  GeneratePlan()
      : super(name: 'generatePlan', description: """
    Generate a personalized learning plan based on the user's information.
    If the user has confirmed their goal, generate a plan.

    1. Structure the learning plan in the following format:
      - **Goal X**: High-level goal title with total duration and total number of lessons.
      - For each goal, divide it into subgoals:
        - **Subgoal X.X**: Subgoal title with duration and total number of lessons.
        - For each subgoal, list the lessons in sequence:
          - **Lesson X.X.X**: Lesson title with duration (10-15 min max).
      - Include optional practice and review lessons for consolidation at the end of each subgoal.
    2. Use the user's stated goal to define the primary focus of the plan, and analyze their chat history to tailor lessons to their current proficiency, interests, and needs.
    3. Ensure the total duration and number of lessons for each subgoal and goal are realistic, breaking down learning into manageable sessions.
    """, inputJsonSchema: {
          '\$defs': {
            'Goal': {
              'properties': {
                'name': {
                  'description': 'The name of the goal.',
                  'type': 'string'
                },
                'duration': {
                  'description':
                      'The duration of the goal, as a sum of subgoals durations.',
                  'type': 'string'
                },
                'subgoals': {
                  'description': 'The subgoals of the goal.',
                  'items': {'\$ref': '#/\$defs/Subgoal'},
                  'type': 'array'
                }
              },
              'required': ['name', 'duration', 'subgoals'],
              'type': 'object'
            },
            'Lesson': {
              'properties': {
                'name': {
                  'description': 'The name of the lesson.',
                  'type': 'string'
                },
                'duration': {
                  'description':
                      'The duration of the lesson, maximum 15 minutes.',
                  'type': 'string'
                }
              },
              'required': ['name', 'duration'],
              'type': 'object'
            },
            'Subgoal': {
              'properties': {
                'name': {
                  'description': 'The name of the subgoal.',
                  'type': 'string'
                },
                'duration': {
                  'description':
                      'The duration of the subgoal, as a sum of lessons durations.',
                  'type': 'string'
                },
                'lessons': {
                  'description': 'The lessons of the subgoal.',
                  'items': {'\$ref': '#/\$defs/Lesson'},
                  'type': 'array'
                }
              },
              'required': ['name', 'duration', 'lessons'],
              'type': 'object'
            }
          },
          'properties': {
            'name': {'description': 'The name of the plan.', 'type': 'string'},
            'duration': {
              'description':
                  'The duration of the plan, as a sum of goals durations. Minimum 1 month.',
              'type': 'string'
            },
            'goals': {
              'description': 'The goals of the plan, minimum 3, maximum 5.',
              'items': {'\$ref': '#/\$defs/Goal'},
              'type': 'array'
            }
          },
          'required': ['name', 'duration', 'goals'],
          'type': 'object'
        });

  @override
  Future<String> invokeInternal(
    final Map<String, dynamic> toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      // Assuming the map has the structure you expect.;
      await learningPlanFile.writeAsString(encoder.convert(toolInput));

      return toolInput.toString(); // Return the plan as output
    } catch (e) {
      return "I don't know how to generate a plan.";
    }
  }

  @override
  Map<String, dynamic> getInputFromJson(final Map<String, dynamic> json) {
    // This method is responsible for parsing the JSON input into the expected Map type
    return json; // Returning the whole json as is (you can add more custom deserialization if needed)
  }
}
