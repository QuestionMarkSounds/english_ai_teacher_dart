import 'dart:io';
import 'package:langchain/langchain.dart';
import 'dart:convert';
import 'json_schemas.dart';

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

final class GeneratePlan
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final void Function(Map<String, dynamic> output) callback;
  GeneratePlan(this.callback)
      : super(
            name: 'generatePlan',
            description: """
              Generate a personalized learning plan to help the user reach the next English proficiency level quickly.
              If the user confirms their goal, generate a personalized learning plan.

              1. **Plan Structure**:
                - **Goal X**: Defines the target level, duration, and lesson count.
                - **Subgoal X.X**: Focuses on key skills with structured lessons.
                - **Lesson X.X.X**: Short (10–15 min) sessions in sequence.
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
