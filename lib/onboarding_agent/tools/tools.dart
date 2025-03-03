import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import 'json_schemas.dart';

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

final class CommitPlanToUserAccount extends StringTool {
  final String? userID;
  final void Function(String?) callback;
  CommitPlanToUserAccount(this.callback, this.userID)
      : super(
            name: 'commitPlanToUserAccount',
            description:
                'Commits generated plan to user account. No need to input the plan into this tool.');

  @override
  Future<String> invokeInternal(
    final String toolInput, {
    final ToolOptions? options,
  }) async {
    callback(userID);
    return "Plan committed to user account.";
  }
}

final class GeneratePlan
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final void Function(Map<String, dynamic> output) callback;
  GeneratePlan(this.callback)
      : super(
            name: 'generatePlan',
            description: """
              1. **Plan Structure**:
                - **Goal X**: Defines the target level, duration, and lesson count. Provide a name, duration, and subgoals for the goal.
                - **Subgoal X.X**: Focuses on key skills with structured lessons. Provide a name, duration, and lessons for each subgoal.
                - **Lesson X.X.X**: Short (10–15 min) sessions in sequence. Provide a name and duration (integer) in minutes for each lesson.
                - Includes optional practice and review for reinforcement.
              2. **Customization**:
                - Tailored to the user’s proficiency, goals, and interests.
                - Adjusted based on chat history for relevance.
                - Ensures steady and measurable progress.
              3. **Efficiency**:
                - Lessons are focused and manageable.
                - Duration and lesson count are realistic.
                - Designed for rapid progression to the next level.
              """,
            inputJsonSchema: generatePlanSchema);
  @override
  Future<String> invokeInternal(
    final Map<String, dynamic> toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      final String output =
          encoder.convert(toolInput); // Return the plan as output
      callback(toolInput);
      return output;
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

final class GeneratePlanSmartLlm extends StringTool {
  final ChatOpenAI smartLlm;
  late OpenAIQAWithStructureChain smartLlmChain;
  final void Function(Map<String, dynamic> output) callback;
  GeneratePlanSmartLlm(this.callback, this.smartLlm)
      : super(name: 'generatePlan', description: """
              Use this tool whenever the user confirms their learning goal to generate a personalized learning plan.
              This tool calls a plan generator assistant. Make sure you provide a detailed plan and mention details about the user so the assistant can generate the best plan.
              1. **Plan Structure**:
                - **Goal X**: Defines the target level, duration, and lesson count.
                - **Subgoal X.X**: Focuses on key skills with structured lessons.
                - **Lesson X.X.X**: Short (10–15 min) sessions in sequence.
                - Includes optional practice and review for reinforcement.
              """) {
    final promptTemplate = ChatPromptTemplate.fromTemplates(
      [
        (
          ChatMessageType.system,
          """
            Generate a personalized learning plan based on the information provided in the input.

            1. **Plan Structure**:
              - **Goal X**: Defines the target level, duration, and lesson count. Provide a name, duration, and subgoals for the goal.
              - **Subgoal X.X**: Focuses on key skills with structured lessons. Provide a name, duration, and lessons for each subgoal.
              - **Lesson X.X.X**: Short (10–15 min) sessions in sequence. Provide a name and duration (integer) in minutes for each lesson.
              - Includes optional practice and review for reinforcement.

            2. **Customization**:
              - Tailored to the user’s proficiency, goals, and interests.
              - Adjusted based on chat history for relevance.
              - Ensures steady and measurable progress.

            3. **Efficiency**:
              - Lessons are focused and manageable.
              - Duration and lesson count are realistic.
              - Designed for rapid progression to the next level.

            input: {input}
            """
        ),
      ],
    );
    smartLlmChain = OpenAIQAWithStructureChain(
      prompt: promptTemplate,
      llm: smartLlm,
      tool: ToolSpec(
        name: "Answer",
        description: "Follow this reply structure",
        inputJsonSchema: generatePlanSchema,
      ),
      outputParser: ToolsOutputParser(),
    );
  }

  @override
  Future<String> invokeInternal(
    String toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      Map<String, dynamic> plan =
          await smartLlmChain.invoke({"input": toolInput});
      print("PLAN:\n${plan}");
      final String output = encoder
          .convert(plan["output"][0].arguments); // Return the plan as output

      callback(plan["output"][0].arguments);
      return output;
    } catch (e) {
      print(e);
      return "I don't know how to generate a plan.";
    }
  }
}

final class UpdateUserData
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final void Function(Map<String, dynamic> output) callback;
  UpdateUserData(this.callback)
      : super(
            name: 'updateUserData',
            description: """
    Use this tool whenever the user provides new information about themselves.  
    Record and update all details shared by the user accurately and in English.  

    Always use this tool when the user shares any information about themselves. 
    If the user mentions their language and it is unfamiliar, make your best guess based on context.  

    The tool will return the updated user information.
    """,
            inputJsonSchema: updateUserDataSchema);

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

      final Map<String, dynamic> userInformationJson = {
        "Name": name,
        "Native Language": nativeLanguage,
        "Reason to Learn English": reason,
        "Interests": interests,
        "Current Level of English": currentLevel,
      };
      callback(userInformationJson);
      return encoder.convert(
          userInformationJson); // Return the user information as output
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
