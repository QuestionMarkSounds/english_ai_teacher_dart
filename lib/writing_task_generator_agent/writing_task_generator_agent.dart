import 'package:langchain/langchain.dart';
import 'package:retry/retry.dart';
import 'package:langchain_openai/langchain_openai.dart';
import '../src/json_memory_manager.dart';

import 'package:dotenv/dotenv.dart';

var env = DotEnv()..load();

ChatOpenAI chatModel = ChatOpenAI(
  apiKey: env["OPENAI_API_KEY"],
  defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"),
);

Future<dynamic> runWritingTaskGeneratorAgent({
  required String userId,
  required String filePath,
  required BaseChatModel chatModel,
  required String taskName,
  required String taskDescription,
  required String taskObjective,
  required String taskVariations,
  required String englishLevel,
  Map<String, dynamic>? taskOutputJsonSchema,
  String? topic,
}) async {
  String writingTaskGeneratorAgentSystemPrompt = """
  Generate a writing task for practice in $englishLevel level English. 
  Keep in mind that the vocabulary and complexity of the task must be appropriate for $englishLevel level.
  
  Task: $taskName. 
  Task description: $taskDescription. 
  Task objective: $taskObjective. 
  Task variations: $taskVariations. 

  Topic: ${topic ?? "miscellaneous"}.

  Reply with the writing task and the ideal answer to it.

  """;
  final promptTemplate = ChatPromptTemplate.fromTemplates([
    (ChatMessageType.system, writingTaskGeneratorAgentSystemPrompt),
  ]);

  OpenAIQAWithStructureChain chain = OpenAIQAWithStructureChain(
    prompt: promptTemplate,
    llm: ChatOpenAI(
      apiKey: env["OPENAI_API_KEY"],
      defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"),
    ),
    tool: ToolSpec(
      name: "Answer",
      description: "Follow this reply structure",
      inputJsonSchema: taskOutputJsonSchema ??
          {
            "properties": {
              "exercise": {
                "default": "Generated exercise",
                "title": "",
                "type": "string"
              },
              "ideal_answer": {
                "default": "Generated ideal answer",
                "title": "Ideal Answer",
                "type": "string"
              }
            },
            "title": "Answer",
            "type": "object"
          },
    ),
    outputParser: ToolsOutputParser(),
  );

  return await chain.invoke({});
}
