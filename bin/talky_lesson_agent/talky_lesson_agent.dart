import 'package:dotenv/dotenv.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:retry/retry.dart';
import '../json_memory_manager.dart';
// import 'tools/tools.dart';

var env = DotEnv()..load();

ChatOpenAI chatModel = ChatOpenAI(
  apiKey: env["OPENAI_API_KEY"],
  defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"),
);

class TalkyLessonAgent {
  final BaseChatModel llm;
  final BaseUserInfoChatMemory? memoryManager;
  final String proficiencyLevel;
  List<ChatMessage> messages = [];
  List<ChatMessage> assessmentMessages = [];

  final promptTemplate = ChatPromptTemplate.fromTemplates([
    (ChatMessageType.human, '{question}'),
  ]);

  TalkyLessonAgent(
      {required this.llm, required this.proficiencyLevel, this.memoryManager});

  Future<String> askQuestion() async {
    final systemPrompt = ChatMessage.system('''
Follow up on a conversation based on chat history. 
Create an open ended question on a miscellaneous topic 
(What do you think... What were you... etc.).

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
    messages.add(ChatMessage.ai(result));
    return result;
  }

  Future<String> replyToUser(String input) async {
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
    return result;
  }

  Future<String> completeLesson() async {
    final systemPrompt = ChatMessage.system('''
Based on AI suggestions, compose a short summary of the lesson. 
Congratulate user on lesson completion.

Keep in mind user's proficiency level: $proficiencyLevel 

''');
    String result = '';
    final prompt = PromptValue.chat([systemPrompt] + assessmentMessages);
    await retry(
      () async {
        final res = await llm.invoke(prompt);
        result = res.outputAsString;
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    return result;
  }
}

// Future<TalkyLessonAgent> createTalkyLessonAgent(
//     {required String userId,
//     required String filePath,
//     required BaseChatModel chatModel}) async {
//   const String TalkyLessonAgentSystemPrompt = """
//   You are an onboarding assistant for an English-learning app. Guide the user step by step to gather their name, native language, and learning goals.
//   If the user confirms their goal, generate a personalized learning plan.
//   If a plan is generated, confirm satisfaction before encouraging subscription.
//   """;
//   final memoryManager = await JsonMemoryManager.create(
//       memoryFilePath: filePath,
//       userId: userId,
//       systemPrompt: TalkyLessonAgentSystemPrompt);
//   return TalkyLessonAgent(llm: chatModel, memoryManager: memoryManager);
// }
