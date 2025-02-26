import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:retry/retry.dart';

import '../src/globals.dart';
import '../src/helper.dart';

// ----------------------------
// The main task of the talky
// is to chat and provide immediate
// feedback to the user, as well as
// a final evaluation.
// ----------------------------

// Constructing the agent class
class TalkyLessonAgent {
  final String proficiencyLevel;
  final String? topic;
  List<ChatMessage> assessmentMessages = [];

  // Constructor
  TalkyLessonAgent({required this.proficiencyLevel, this.topic});

  // Ask Question method. Used to ask the user a question
  Future<Map<String, dynamic>> askQuestion(
      List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final systemPrompt = ChatMessage.system('''
      Follow up on a conversation based on chat history. 
      Create a complex open ended question on a ${topic ?? "miscellaneous"} topic 
      (What do you think... What were you... etc.).

      Keep in mind user's proficiency level: $proficiencyLevel 

      ''');
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    final prompt = PromptValue.chat([systemPrompt] + messages);
    String response = '';
    await retry(
      () async {
        final res = await chatModel.invoke(prompt);
        response = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    messages.add(ChatMessage.ai(response));
    return {"assistant": response};
  }

  // Reply with Improvement method. Used to give user improvement suggestions
  Future<List<Map<String, dynamic>>> replyWithImprovement(
      String input,
      List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    messages.add(ChatMessage.humanText(input));

    final promptTemplate = ChatPromptTemplate.fromTemplates([
      (
        ChatMessageType.system,
        '''
      You are an English language teacher. Analyse the latest user message.
      Respond with a short assessment of English language proficiency and 
      improvement suggestions if appropriate. Max 3 sentences. Don't use bullet points. Include rephrased user message if appropriate.

      Keep in mind user's proficiency level: $proficiencyLevel.
      Do not include or reiterate the user's message in the response!
      In case if there are no issues with the user's English considering the user's proficiency level, respond with an empty response.

      Things that don't count as a mistake:
      - the message is clear but could be simplified. Does not count as a mistake for english levels A1, A2 and B1.
      '''
      ),
      (ChatMessageType.human, 'input'),
      (ChatMessageType.messagesPlaceholder, 'messageHistory')
    ]);

    String response = '';
    OpenAIQAWithStructureChain chain = OpenAIQAWithStructureChain(
      prompt: promptTemplate,
      llm: chatModel,
      tool: ToolSpec(
        name: "Response",
        description: "",
        inputJsonSchema: {
          "properties": {
            "mistakes_present": {
              "default": "True if mistakes are present, False if not",
              "title": "Mistakes Present",
              "type": "boolean"
            },
            "response": {
              "default":
                  """Respond with a short assessment of English language proficiency and 
      improvement suggestions if appropriate. Max 3 sentences. Don't use bullet points. Include rephrased user message if appropriate.

      Keep in mind user's proficiency level: $proficiencyLevel
      Do not include the user's message in the response!
      In case if there are no issues with the user's English considering the user's proficiency level, respond with an empty response.""",
              "title": "Response",
              "type": "string"
            }
          },
          "title": "Response",
          "type": "object"
        },
      ),
      outputParser: ToolsOutputParser(),
    );
    List<Map<String, dynamic>> output = [
      {"user": input},
    ];
    await retry(
      () async {
        final res =
            await chain.invoke({"input": input, "messageHistory": messages});

        final pydanticResponse = res["output"][0].arguments;
        bool mistakesPresent = pydanticResponse["mistakes_present"];
        if (mistakesPresent) {
          output.add({"assistant": pydanticResponse["response"]});
        }
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    assessmentMessages.add(ChatMessage.ai(response));
    return output;
  }

  // Complete Lesson method. Used to complete the lesson with a summary
  Future<Map<String, dynamic>> completeLesson(
      List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final systemPrompt = ChatMessage.system('''
      Compose a short summary of the messages from the history that imply any remarks on English language usage. 
      Focus on English language usage and keep in mind user's proficiency level: $proficiencyLevel.
      Disregard AI messages that have questions. 
      Don't focus on the latest user message. Process all the messages from the history.
      Congratulate user on lesson completion.

      ''');
    String response = '';
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    final prompt = PromptValue.chat([systemPrompt] + messages);

    await retry(
      () async {
        final res = await chatModel.invoke(prompt);
        response = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    return {"assistant": response};
  }
}
