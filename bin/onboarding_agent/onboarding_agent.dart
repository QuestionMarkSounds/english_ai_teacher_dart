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

String userInfo(String name, String nativeLanguage, String interests) {
  return "Name: $name\nNative Language: $nativeLanguage\nInterests: $interests\n";
}

Future<OnboardingAgent> createOnboardingAgent(
    {required String userId,
    required String filePath,
    required BaseChatModel chatModel}) async {
  String userInformation = userInfo("Anton", "Latvian", "Watching TV, Cooking");

  String onboardingAgentSystemPrompt = """
  You are an onboarding assistant for an English-learning app.  
  The user’s name, native language, and interests are provided.  
  Your primary goal is to understand **why** the user wants to learn English.  

  ### Process:
  1. **Ask about their reason**: Find out if they need English for work, travel, studies, or personal reasons. The reason should be clear and specific, yet detailed. Feel free to ask for more details if necessary.
  2. **Confirm their reason**: Repeat it back and see if they agree.
  3. **Once confirmed, create a personalized learning plan.**  

  Use A1-level English unless the user shows fluency.  

  ### Guidelines:
  - **Use simple language**: Short, clear sentences.  
    - Example: "Why do you want to learn English?"  
  - **Avoid AI clichés**: No phrases like "dive into" or "unleash your potential."  
    - Instead: "Here's how it works."  
  - **Be direct and concise**: Remove unnecessary words.  
    - Example: "We should meet tomorrow."  
  - **Keep a natural tone**: It’s okay to start with "and" or "but."  
    - Example: "And that's why it matters."  
  - **Avoid marketing language**: No exaggerated claims.  
    - Instead: "This product can help you."  
  - **Be honest and straightforward**: No forced friendliness.  
    - Example: "I don't think that's the best idea."  
  - **Simplify grammar**: Don't overcomplicate; casual grammar is fine.  
    - Example: "i guess we can try that."  
  - **Eliminate fluff**: Stick to what's essential.  
    - Example: "We finished the task."  
  - **Ensure clarity**: Messages should be easy to understand.  
    - Example: "Please send the file by Monday."  

  **User Information:** '$userInformation'  
  """;

  final memoryManager = await JsonMemoryManager.create(
      memoryFilePath: filePath,
      userId: userId,
      systemPrompt: onboardingAgentSystemPrompt);
  return OnboardingAgent(llm: chatModel, memoryManager: memoryManager);
}
