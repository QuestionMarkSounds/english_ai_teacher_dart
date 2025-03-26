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
  late String systemPrompt;
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
    systemPrompt = '''
          You are an English language teacher that is practicing a conversation with the user.

          Do not correct the user's usage of English.

          {stt_warning}

          You are required to collect at least $maxIterations responses from the user. The number of user responses will be included below.

          Once there is a sufficient number of user responses, you should  use CompleteLesson tool to compose a summary of the lesson and to end the lesson.
          
          You must NOT use CompleteLesson tool to end the lesson if number of user responses is $maxIterations or above **AND** the user seeks for information either by asking a question or by expressing confusion in his latest message.
          For example, if user does not understand something, seeks clarification, or asks a question in his latest message, you must continue the lesson.
          Otherwise, You must use CompleteLesson tool to compose a summary of the lesson and to end the lesson if number of user responses is $maxIterations or above **AND** the conversation is going nowhere.
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
      Map<String, dynamic>? userInfo, bool isVoiceMsg) async {
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    int responseCount = countHumanMessagesInHistory(messageHistory);
    final latestUserMessage = getLatestUserMessage(messages);

    String response = '';
    print("Response count: $responseCount");
    await retry(
      () async {
        final res = await executor.invoke({
          'message_history': messages,
          'number_of_responses': responseCount,
          'input': latestUserMessage != null ? latestUserMessage.contentAsString : '',
          'stt_warning': isVoiceMsg? "WARNING: This input is an interpretation from a speech-to-text engine which is prone to generate erroneous periods in places where a user made a pause. Disregard erroneous periods." : ""
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
      Map<String, dynamic>? userInfo, bool isVoiceMsg) async {
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    messages.add(ChatMessage.humanText(input));

    final improvementReplySystemPrompt =         '''
      
      ${isVoiceMsg? "WARNING: This input is an interpretation from a speech-to-text engine which is prone to generate erroneous periods in places where a user made a pause. Disregard erroneous periods." : ""}

      You are an English language teacher. Analyse the latest user message.

      Keep in mind user's proficiency level: $proficiencyLevel.
      Do not include or reiterate the user's message in the response!
      In case if there are no issues with the user's English considering the user's proficiency level, respond with an empty response.

      Do not mention mistakes that do not count as a mistake.

      DO NOT COUNT THESE ISSUES AS MISTAKES:
      - Minor phrasing issues are not a mistake.
      - the message is clear but could be simplified. This is not a mistake
      ${isVoiceMsg? "- capitalization issues are not a mistake\n- punctuation issues including erroneous periods are not a mistake. \nFor example: **I think the Most important locations while. Traveling are your hotel. Grocery store, and drug store. As well as public transport stops.** This sentence has no mistakes" : ""}
      ''';
    final promptTemplate = ChatPromptTemplate.fromTemplates([
      (
        ChatMessageType.system,
        improvementReplySystemPrompt
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
        "title": "Response",
        "type": "object",
        "properties": {
          "mistakes_present": {
            "title": "Mistakes Present",
            "type": "boolean",
            "description": "Set to true if any mistakes are present, false otherwise. Do not count the following as mistakes: minor phrasing issues, oversimplified clarity, and—if this is a voice message—erroneous periods, punctuation, or capitalization errors."
          },
          "mistakes_types": {
            "title": "Types of Mistakes Present",
            "type": "string",
            "description": "Describe the types of mistakes present, if any."
          },
          "response": {
            "title": "Response",
            "type": "string",
            "description": "Provide a short assessment of the user's English language proficiency and any improvement suggestions if appropriate. Use a maximum of 3 sentences without bullet points. Optionally include a rephrased version of the user message, but do not include or reiterate the original message. Keep in mind the user's proficiency level: $proficiencyLevel. In case there are no issues with the user's English given their proficiency level, respond with an empty response."
          }
        }
      }

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
    String response = '';
    await retry(
      () async {
        final res = await chatModel.invoke(PromptValue.chat([
          ChatMessage.system(systemPrompt + "\n\n" + "The user did not send any messages yet. Start the lesson with your first message."),
        ]));
        response = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    return response;
  }

  Future<String> stream(String input, List<Map<String, dynamic>> messageHistory,
      String userInformation, {bool isVoiceMsg = false}) async {
    final llmReplies = await Future.wait([
      replyWithImprovement(input, messageHistory, null, isVoiceMsg),
      askQuestion(
          messageHistory +
              [
                {"user": input}
              ],
          null, isVoiceMsg)
    ]);

    final output = llmReplies[0] != null
        ? "${llmReplies[0]!}\n\n${llmReplies[1]!}"
        : llmReplies[1]!;

    return output;
  }
}
