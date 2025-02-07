import 'dart:io';
import 'package:langchain/langchain.dart';
import 'dart:convert';
import 'json_schemas.dart';

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

final class GeneratePlan
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final String userId;

  GeneratePlan(this.userId)
      : super(
            name: 'generatePlan',
            description: """
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
    """,
            inputJsonSchema: generatePlanSchema);
  @override
  Future<String> invokeInternal(
    final Map<String, dynamic> toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      File learningPlanFile = File('learning_plan.json');
      // Assuming the map has the structure you expect.;
      Map<String, dynamic> learningPlanDb =
          jsonDecode(await learningPlanFile.readAsString());
      learningPlanDb[userId] = toolInput;
      await learningPlanFile.writeAsString(encoder.convert(learningPlanDb));

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

final class UpdateUserData
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final String userId;
  UpdateUserData(this.userId)
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
      File userInfoFile = File('user_info.json');
      Map<String, dynamic> userInfoDb =
          jsonDecode(await userInfoFile.readAsString());
      userInfoDb[userId] = userInformationJson;
      await userInfoFile.writeAsString(encoder.convert(userInfoDb));

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
