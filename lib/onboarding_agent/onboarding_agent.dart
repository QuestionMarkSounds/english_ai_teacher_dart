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
  Your primary goal is to understand **why** the user wants to learn English.  

  ### Process:
  1. **Ask about their reason**: Find out if they need English for work, travel, studies, or personal reasons. The reason should be clear and specific, yet detailed. Feel free to ask for more details if necessary.
  2. **Confirm their reason**: Repeat it back and see if they agree.
  3. **Once confirmed, create a personalized learning plan by using a tool.**  

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
          GeneratePlan(generatePlanCallback)
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
    final promptJson = promptTemplate.format({
      'question':
          "Start the conversation by greeting me and asking me why I want to learn english without acknowledging that I asked you to.",
      'message_history': processMessageHistory(messageHistory),
      'userInformation': userInformation
    });
    String response = "";

    await retry(
      () async {
        response = await executor.run(promptJson);
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
