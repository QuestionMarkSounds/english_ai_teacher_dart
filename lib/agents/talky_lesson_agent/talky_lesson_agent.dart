import 'dart:math';

import 'package:english_ai_teacher/src/agent_executor_with_next_step_callback.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:retry/retry.dart';

import '../../src/globals.dart';
import '../../src/helper.dart';

import 'tools.dart';

// ----------------------------
// The main task of the talky
// is to chat and provide immediate
// feedback to the user, as well as
// a final evaluation on whether the
// user is ready for the next step.
// ----------------------------

// Constructing the agent class
class TalkyLessonAgent {
  final String proficiencyLevel;
  final String lessonSystemPrompt;
  final int maxIterations;
  late BaseChain executor;
  final void Function(Map<String, dynamic>) lessonCompleteCallback;

  List<ChatMessage> assessmentMessages = [];

  // Constructor
  TalkyLessonAgent({
    required this.proficiencyLevel,
    required this.lessonSystemPrompt,
    required this.lessonCompleteCallback,
    this.maxIterations = 3,
  }) {
    final systemPrompt = '''
          You are an English language teacher that is practicing a conversation with the user.
          You are required to collect at least $maxIterations responses from the user. The number of user responses will be included below.

          Once there is a sufficient number of user responses, you might continue the lesson only if the latest user message implies that the user seeks for information.
          
          You must NOT end the lesson if number of user responses is $maxIterations or above **AND** the user seeks for information either by asking a question or by expressing confusion in his latest message.
          For example, if user does not understand something, seeks clarification, or asks a question in his latest message, you must continue the lesson for .
          Otherwise, You must end the lesson if number of user responses is $maxIterations or above **AND** the conversation is going nowhere.
          In any other case, use CompleteLesson tool to compose a summary of the lesson and to end the lesson.

          Follow up on a conversation based on chat history. 
          Description of the lesson: $lessonSystemPrompt. 

          Keep in mind user's proficiency level: $proficiencyLevel. 

          Number of user responses {number_of_responses}

          ''';

    final agent = ToolsAgent.fromLLMAndTools(
        llm: chatModel,
        tools: [
          CompleteLesson(
            callback: lessonCompleteCallback,
          )
        ],
        systemChatMessage:
            SystemChatMessagePromptTemplate.fromTemplate(systemPrompt),
        extraPromptMessages: [
          ChatMessagePromptTemplate.messagesPlaceholder('message_history'),
        ]);

    executor = AgentExecutorWithNextStepCallback(
      agent: agent,
      toolUsageCallback: (String a) {
        print(a);
      },
    );
  }

  // Ask Question method. Used to ask the user a question
  Future<String> askQuestion(List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    int responseCount = countHumanMessagesInHistory(messageHistory);
    final latestUserMessage = getLatestUserMessage(messages);

    String response = '';
    await retry(
      () async {
        final res = await executor.invoke({
          'message_history': messages,
          'number_of_responses': responseCount,
          'input': latestUserMessage.contentAsString,
        });
        response = res["output"];
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    messages.add(ChatMessage.ai(response));
    return response;
  }

  // Reply with Improvement method. Used to give user improvement suggestions
  Future<String?> replyWithImprovement(
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
    String? output;
    await retry(
      () async {
        final res =
            await chain.invoke({"input": input, "messageHistory": messages});

        final pydanticResponse = res["output"][0].arguments;
        bool? mistakesPresent = pydanticResponse["mistakes_present"];
        if (mistakesPresent != null && mistakesPresent) {
          output = pydanticResponse["response"];
        }
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    assessmentMessages.add(ChatMessage.ai(response));
    return output;
  }

  Future<String> greet(
      List<Map<String, dynamic>> messageHistory, String userInformation) async {
    final response = await askQuestion(messageHistory, null);
    return response;
  }

  Future<String> stream(String input, List<Map<String, dynamic>> messageHistory,
      String userInformation) async {
    final llmReplies = await Future.wait([
      replyWithImprovement(input, messageHistory, null),
      askQuestion(
          messageHistory +
              [
                {"user": input}
              ],
          null)
    ]);

    final output = llmReplies[0] != null
        ? "${llmReplies[0]!}\n\n${llmReplies[1]!}"
        : llmReplies[1]!;

    return output;
  }
}
