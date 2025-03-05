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
        Create $numberOfLessons exercise constructors for a subgoal named "$subgoalName" with a duration of $subgoalDuration minutes.

        Use the following information:

        The complete exercise will be generated later by a large language model. 
        Your task is to make a system prompt for a conversational LLM that will guide LLM to ask user questions and maintain conversation.
        Use an example system prompt from below when creating the system prompt.:

        Output system prompt example: ${exerciseTypes[exerciseType]["prompt_example"]}.

        Additional information:
        - Exercise description: ${exerciseTypes[exerciseType]["description"]}
        - Information about the user: ${userInfo.toString().replaceAll("{", "").replaceAll("}", "")}
        - Plan name: $planName
        - Goal name: $goalName
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
