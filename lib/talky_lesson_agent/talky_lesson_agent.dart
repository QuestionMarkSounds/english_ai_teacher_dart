import 'package:dotenv/dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:retry/retry.dart';

import '../src/helper.dart';

var env = DotEnv()..load();

ChatOpenAI chatModel = ChatOpenAI(
  apiKey: env["OPENAI_API_KEY"],
  defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"),
);

class TalkyLessonAgent {
  final BaseChatModel llm;
  final String proficiencyLevel;
  final String? topic;
  List<ChatMessage> assessmentMessages = [];

  final promptTemplate = ChatPromptTemplate.fromTemplates([
    (ChatMessageType.human, '{question}'),
  ]);

  TalkyLessonAgent(
      {required this.llm, required this.proficiencyLevel, this.topic});

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
    String result = '';
    await retry(
      () async {
        final res = await llm.invoke(prompt);
        result = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    messages.add(ChatMessage.ai(result));
    return {"assistant": result};
  }

  Future<List<Map<String, dynamic>>> replyToUser(
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
    String result = '';
    await retry(
      () async {
        final res = await llm.invoke(prompt);
        result = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    assessmentMessages.add(ChatMessage.ai(result));
    return [
      {"user": input},
      {"assistant": result}
    ];
  }

  Future<Map<String, dynamic>> completeLesson(
      List<Map<String, dynamic>> messageHistory,
      Map<String, dynamic>? userInfo) async {
    final systemPrompt = ChatMessage.system('''
  Based on AI suggestions, compose a short summary of the lesson. 
  Congratulate user on lesson completion.

  Keep in mind user's proficiency level: $proficiencyLevel 

  ''');
    String result = '';
    final List<ChatMessage> messages = processMessageHistory(messageHistory);
    final prompt = PromptValue.chat([systemPrompt] + messages);
    await retry(
      () async {
        final res = await llm.invoke(prompt);
        result = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    return {"assistant": result};
  }
}
