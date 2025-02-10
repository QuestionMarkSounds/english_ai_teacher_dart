import 'package:langchain/langchain.dart';
import 'package:retry/retry.dart';
import '../json_memory_manager.dart';
import 'tools/tools.dart';

class OnboardingAgent {
  final BaseChatModel llm;
  final BaseChain executor;
  final BaseUserInfoChatMemory memoryManager;

  final promptTemplate = ChatPromptTemplate.fromTemplates([
    (ChatMessageType.human, '{question}'),
  ]);

  OnboardingAgent({required this.llm, required this.memoryManager})
      : executor = init(memoryManager, llm);

  static BaseChain init(
      BaseUserInfoChatMemory memoryManager, BaseChatModel llm) {
    final agent = ToolsAgent.fromLLMAndTools(
        llm: llm,
        tools: [
          UpdateUserData(memoryManager.userId),
          GeneratePlan(memoryManager.userId)
        ],
        memory: memoryManager);
    return AgentExecutor(agent: agent);
  }

  Future<String> invoke(String input) async {
    final formattedPrompt = promptTemplate.format({'question': input});
    String response = "";
    await retry(
      () async {
        response = await executor.run(formattedPrompt);
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    await memoryManager.save();
    return response;
  }
}

Future<OnboardingAgent> createOnboardingAgent(
    {required String userId,
    required String filePath,
    required BaseChatModel chatModel}) async {
  const String onboardingAgentSystemPrompt = """
  You are an onboarding assistant for an English-learning app. Guide the user step by step to gather their name, native language, and learning goals.
  If the user confirms their goal, generate a personalized learning plan.
  If a plan is generated, confirm satisfaction before encouraging subscription.
  """;
  final memoryManager = await JsonMemoryManager.create(
      memoryFilePath: filePath,
      userId: userId,
      systemPrompt: onboardingAgentSystemPrompt);
  return OnboardingAgent(llm: chatModel, memoryManager: memoryManager);
}
