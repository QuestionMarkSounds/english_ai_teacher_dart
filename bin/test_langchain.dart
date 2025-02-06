import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:retry/retry.dart';
import 'dart:convert';
import 'json_memory_manager.dart';
import 'package:dotenv/dotenv.dart';

var env = DotEnv()..load();
final chatModel = ChatOpenAI(
    apiKey: env["OPENAI_API_KEY"],
    defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"));

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

// -----------------------
// MEMORY SECTION
// -----------------------

final memoryLlm = ConversationBufferMemory(returnMessages: true);
File memoryFile = File('memory.json');
late JsonMemoryManager memoryManager;

final memoryJson = [];

File userInfoFile = File('user_info.json');
File learningPlanFile = File('learning_plan.json');

// -----------------------
// TOOL SECTION
// -----------------------

final class UpdateUserData
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  UpdateUserData()
      : super(name: 'updateUserData', description: """
    Use this tool whenever the user provides new information about themselves.  
    Record and update all details shared by the user accurately and in English.  

    Always use this tool when the user shares any information about themselves. 
    If the user mentions their language and it is unfamiliar, make your best guess based on context.  

    The tool will return the updated user information.
    """, inputJsonSchema: {
          'type': 'object',
          'properties': {
            'name': {
              'type': 'string',
              'description':
                  'The name of the user. Should always be recorded in English and capitalized.'
            },
            'native_language': {
              'type': 'string',
              'description':
                  'The native language of the user. Use your best guess based on context.'
            },
            'reason_to_learn_english': {
              'type': 'string',
              'description':
                  'The goal of the user for learning the language. Be as descriptive as possible.'
            },
            'interests': {
              'type': 'string',
              'description': 'The interests of the user.'
            },
            'current_level_of_english': {
              'type': 'string',
              'description':
                  'The current level of English of the user. From A1 to C2. No fictional levels.'
            },
            'goal_confirmed': {
              'type': 'boolean',
              'description':
                  'Defaults to false. Set to true if the user explicitly confirmed their learning goal.'
            },
            'plan_confirmed': {
              'type': 'boolean',
              'description':
                  'Defaults to false. Set to true if the user explicitly confirmed their learning plan.'
            }
          },
          'required': [
            'name',
            'native_language',
            'reason_to_learn_english',
            'interests',
            'current_level_of_english',
            'goal_confirmed',
            'plan_confirmed'
          ]
        });

  @override
  Future<String> invokeInternal(
    final Map<String, dynamic> toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      // Assuming the map has the structure you expect.
      final String name = toolInput['name'] as String;
      final String nativeLanguage = toolInput['native_language'] as String;
      final String reason = toolInput['reason_to_learn_english'] as String;
      final String interests = toolInput['interests'] as String;
      final String currentLevel =
          toolInput['current_level_of_english'] as String;

      final String userInformation = '''
        Name: $name
        Native Language: $nativeLanguage
        Reason to Learn English: $reason
        Interests: $interests
        Current Level of English: $currentLevel
      ''';

      final Map<String, dynamic> userInformationJson = {
        "Name": name,
        "Native Language": nativeLanguage,
        "Reason to Learn English": reason,
        "Interests": interests,
        "Current Level of English": currentLevel,
      };

      await userInfoFile.writeAsString(encoder.convert(userInformationJson));

      return userInformation; // Return the user information as output
    } catch (e) {
      return "I don't know how to process this data.";
    }
  }

  @override
  Map<String, dynamic> getInputFromJson(final Map<String, dynamic> json) {
    // This method is responsible for parsing the JSON input into the expected Map type
    return json; // Returning the whole json as is (you can add more custom deserialization if needed)
  }
}

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

// -----------------------
// PROMPT SECTION
// -----------------------

String systemPrompt = """
  You are an onboarding assistant for an English-learning app. Guide the user step by step to gather their name, native language, and learning goals.
  If the user confirms their goal, generate a personalized learning plan.
  If a plan is generated, confirm satisfaction before encouraging subscription.
""";

final promptTemplate = ChatPromptTemplate.fromTemplates([
  (ChatMessageType.human, '{question}'),
]);

// -----------------------
// MAIN FUNCTION SECTION
// -----------------------

void main() async {
  memoryManager = await JsonMemoryManager.create(
      memoryFilePath: memoryFile.path,
      userId: 'andruha',
      systemPrompt: systemPrompt);
  while (true) {
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    if (userInput == null || userInput.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    final formattedPrompt = promptTemplate.format({'question': userInput});

    final agent = ToolsAgent.fromLLMAndTools(
        llm: chatModel,
        tools: [UpdateUserData(), GeneratePlan()],
        memory: memoryManager);

    final executor = AgentExecutor(agent: agent);

    String response = "";
    await retry(
      () async {
        response = await executor.run(formattedPrompt);
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    await memoryManager.save();
    print('AI: ${response}');
  }
}
