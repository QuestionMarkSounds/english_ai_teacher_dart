import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../../../src/globals.dart';
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
  required Map<String, dynamic> initialPlan,
  required Map<String, dynamic> userInfo,
}) async {
  final promptTemplate = ChatPromptTemplate.fromTemplates(
    [
      (
        ChatMessageType.system,
        """
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
      inputJsonSchema: extendPlanSchema,
    ),
    outputParser: ToolsOutputParser(),
  );

  var result = await chain.invoke({});
  // print(result["output"][0].arguments["lessons"]);
  return result["output"][0].arguments["lessons"];
}
