import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../src/globals.dart';
import 'json_schemas.dart';

Map<String, dynamic> exerciseTypes = {
  "talky_lesson": {
    "description":
        "Conversational exercise that provokes the learner to talk or write about the topic.",
    "prompt_example":
        "Create a complex open ended question on a miscellaneous topic (What do you think... What were you... etc.)..."
  }
};

Future<List<dynamic>> generateLessons({
  required String exerciseType,
  required String subgoalName,
  required String subgoalDuration,
  required Map<String, dynamic> userInfo,
  required int numberOfLessons,
  String? planName,
  String? goalName,
}) async {
  final promptTemplate = ChatPromptTemplate.fromTemplates(
    [
      (
        ChatMessageType.system,
        """
        Generate a structured list of $numberOfLessons lessons for the subgoal "$subgoalName" under the goal "$goalName" in the "$planName" plan. 

        Each lesson should be represented as a JSON object with the following structure:

          "name": "<Lesson Title>",
          "system_prompt": "<AI tutor instructions to facilitate the lesson>",
          "duration": <Lesson Duration in minutes>

        ### Requirements:
        - Ensure each lesson progressively helps the user achieve the subgoal "$subgoalName".
        - Follow the exercise type approach: ${exerciseTypes[exerciseType]["description"]}.
        - Adapt each lesson to match the user's English proficiency level: **${userInfo["english level"]}**.
        - The **system_prompt must be written in third-person, addressing the AI tutor** (e.g., "You are an AI Language Learning tutor...").
        - **Do not** address the user directly. Instead, structure prompts as instructions for an AI tutor.
        - Use the user's details for personalization: ${userInfo.toString().replaceAll("{", "").replaceAll("}", "")}.

        ### **Example system_prompt format:**
        - ✅ Correct:  
          **"You are an AI Language Learning tutor assisting a user in understanding common responses to directions. The topic of this lesson is recognizing and interpreting directional responses. Teach the user to identify key phrases and react accordingly."**  
        - ❌ Incorrect:  
          **"Mukhtar, understanding responses is just as important as asking! I will teach you common responses locals might give when asked for directions."**

        Provide the output as a **valid JSON list**.
        """
      )
    ],
  );

  OpenAIQAWithStructureChain chain = OpenAIQAWithStructureChain(
    prompt: promptTemplate,
    llm: chatModel,
    tool: ToolSpec(
      name: "Answer",
      description: "Follow this reply structure",
      inputJsonSchema: lessonGenSchema,
    ),
    outputParser: ToolsOutputParser(),
  );

  var result = await chain.invoke({});
  // print(result["output"][0].arguments["lessons"]);
  return result["output"][0].arguments["lessons"];
}
