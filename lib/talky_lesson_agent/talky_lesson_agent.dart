import 'package:langchain/langchain.dart';
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

    final systemPrompt = ChatMessage.system('''
      You are an English language teacher. Analyse the latest user message.
      Respond with a short assessment of English language proficiency and 
      improvement suggestions if appropriate. Max 5 sentences. Don't use bullet points. Include rephrased user message.

      Keep in mind user's proficiency level: $proficiencyLevel 
      ''');
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
    assessmentMessages.add(ChatMessage.ai(response));
    return [
      {"user": input},
      {"assistant": response}
    ];
  }

  // Complete Lesson method. Used to complete the lesson with a summary
  Future<Map<String, dynamic>> completeLesson(
      List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final systemPrompt = ChatMessage.system('''
      Based on AI suggestions, compose a short summary of the lesson. 
      Congratulate user on lesson completion.

      Keep in mind user's proficiency level: $proficiencyLevel 

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
