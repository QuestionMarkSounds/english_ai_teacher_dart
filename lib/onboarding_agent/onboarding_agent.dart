import 'package:langchain/langchain.dart';
import 'package:retry/retry.dart';
import 'tools/tools.dart';

import '../src/agent_executor_with_next_step_callback.dart';
import '../src/globals.dart';
import '../src/helper.dart';

// ----------------------------
// The main task of the onboarder
// is to confirm the users reason
// for learning English, and generate
// a personalized learning plan based
// on that.
// ----------------------------

// Constructing the agent class
class OnboardingAgent {
  late BaseChain executor;
  late ChatPromptTemplate promptTemplate;
  final void Function(Map<String, dynamic> output) updateUserCallback;
  final void Function(Map<String, dynamic> output) generatePlanCallback;
  final void Function(String tool) toolUsageCallback;

  // Defining the system prompt
  final String onboardingAgentSystemPrompt = """
    You are an onboarding assistant for an English-learning app.
    The user’s name, native language, and interests are provided.
    Your primary goal is to understand why the user wants to learn English through a step-by-step approach.

    When using tools, use only one tool at a time.

    Process:
    Ask about their general goal:
    Example: "Why do you want to learn English?"
    Possible answers: "For travel," "For work," "For studies," etc.

    Ask for more details:
    Example: "What exactly do you need English for in that context?"
    Possible answers: "To meet new people," "To understand work emails," etc.

    Clarify their focus area:
    Example: "What specific skill do you want to improve?"
    Possible answers: "Speaking and listening," "Writing emails," etc.

    Based on their answers, create a personalized learning plan using a tool.
    Present this plan in a very high-level way, max 3 sentences, and ask the user if he likes it.
    Delve into more detail if the user requests so.
    
    Use A1-level English unless the user shows fluency.

    ### Guidelines:
    - **Use simple language**: Short, clear sentences.  
      - Example: "Why do you want to learn English?"  
    - **Avoid AI clichés**: No phrases like "dive into" or "unleash your potential."  
      - Instead: "Here's how it works."  
    - **Be direct, concise, yet friendly and polite**: Remove unnecessary words.  
      - Example: "Heya, we should meet tomorrow."  
    - **Keep a natural tone**: It’s okay to start with "and" or "but."  
      - Example: "And that's why it matters."  
    - **Avoid marketing language**: No exaggerated claims.  
      - Instead: "This product can help you."  
    - **Simplify grammar**: Don't overcomplicate; casual grammar is fine.  
      - Example: "i guess we can try that."  

    **User Information:** '{userInformation}'  
  """;

  // Constructor
  OnboardingAgent(
      {required this.updateUserCallback,
      required this.generatePlanCallback,
      required this.toolUsageCallback}) {
    promptTemplate = ChatPromptTemplate.fromTemplates([
      (ChatMessageType.system, onboardingAgentSystemPrompt),
      (ChatMessageType.messagesPlaceholder, 'message_history'),
      (ChatMessageType.human, '{question}'),
    ]);
    final agent = ToolsAgent.fromLLMAndTools(
        llm: chatModel,
        tools: [
          UpdateUserData(updateUserCallback),
          GeneratePlan(generatePlanCallback),
        ],
        systemChatMessage: SystemChatMessagePromptTemplate.fromTemplate(
            onboardingAgentSystemPrompt),
        extraPromptMessages: [
          ChatMessagePromptTemplate.messagesPlaceholder('message_history'),
        ]);

    executor = AgentExecutorWithNextStepCallback(
      agent: agent,
      toolUsageCallback: toolUsageCallback,
    );
  }

  // Greet method. Used to start the conversation
  Future<String> greet(
      List<Map<String, dynamic>> messageHistory, String userInformation) async {
    String response = "";
    final prompt = PromptValue.chat([
      ChatMessage.system("Information about the user: $userInformation"),
      ChatMessage.humanText(
          "Start the conversation by greeting me and asking me why I want to learn english without acknowledging that I asked you to.")
    ]);
    await retry(
      () async {
        final res = await chatModel.invoke(prompt);
        response = res.outputAsString;
      },
      retryIf: (e) {
        print("Retrying due to error: $e");
        return true;
      },
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );
    return response;
  }

  // Stream method. Used to continue the conversation and generate a response
  Future<String> stream(String input, List<Map<String, dynamic>> messageHistory,
      String userInformation) async {
    Map<String, dynamic> formattedPrompt = {
      'input': input,
      'message_history': processMessageHistory(messageHistory),
      'userInformation': userInformation
    };
    String response = "";

    await retry(
      () async {
        response = (await executor.call(formattedPrompt))["output"];
      },
      retryIf: (e) => true,
      delayFactor: const Duration(milliseconds: 300),
      maxAttempts: 3,
    );

    return response;
  }
}
