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

final class GeneratePlanSmartLlm extends StringTool {
  final ChatOpenAI smartLlm;
  late OpenAIQAWithStructureChain smartLlmChain;
  final void Function() planGeneratedCallback;
  final void Function(Map<String, dynamic> output) callback;
  GeneratePlanSmartLlm(this.callback, this.smartLlm, this.planGeneratedCallback)
      : super(name: 'generatePlan', description: """
              Use this tool whenever the user confirms their learning goal to generate a personalized learning plan.
              This tool calls a plan generator assistant. Make sure you provide a detailed plan and mention details about the user so the assistant can generate the best plan.
              """) {
    final promptTemplate = ChatPromptTemplate.fromTemplates(
      [
        (
          ChatMessageType.system,
          """
            You are an expert English tutor. Your task is to generate a structured and detailed learning plan based on the user's details. Ensure the plan follows a logical progression, considering the user's current level, goals, and available time.

            ## Key Guidelines:
            1. **Level Progression:**  
              - If the user wants to increase their level, **focus the goal of the plan on the next achievable step (e.g., A2 → B1, not A2 → C1 directly)**.  

            2. **Time Commitment & Learning Pacing:**  
              - Adjust the intensity of the plan based on the user's available hours.  
              - For **15+ hours per week**, prioritize structured immersion (daily speaking, in-depth discussions).  
              - For **fewer hours**, focus on high-impact activities (role-playing, key vocabulary usage).  

            3. **Engagement & Active Learning:**  
              - The user cannot use external tools, so the plan must rely on **chat-based learning** techniques.  
              - Prioritize **conversation-based exercises** (role-playing, debates, storytelling) over passive learning.  
              - Incorporate **real-world application**, such as discussing news, explaining interests, or summarizing content.  

            4. **Feedback & Progress Tracking:**  
              - Encourage self-assessment (recording progress, summarizing key takeaways).  
              - Provide strategies for reinforcement (e.g., reviewing previous discussions, reusing learned vocabulary).  

            ## Expected Output Structure:
            The learning plan should be structured in a json format.

            Each goal should take approximately 1 month to complete.
            Each subgoal should take approximately 1 week to complete.

            Ensure the plan is **practical, engaging, and adaptable** to different learning paces. 

            Include a Plan description which should be in a form of a compound imperative sentence listing at least three benefits of the course.
            **Plan description example**: Master essential skills to excel in job interviews, navigate your first days at work, and accelerate your professional growth.
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
      planGeneratedCallback();
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
