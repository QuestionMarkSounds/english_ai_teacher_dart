import 'package:langchain/langchain.dart';
import 'package:retry/retry.dart';

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
class GeneralAgent {
  late BaseChain executor;
  late ChatPromptTemplate promptTemplate;
  final String? userID;

  // Defining the system prompt
  final String generalAgentSystemPrompt = """
    You are a teacher consultant for an English-learning app.
    The user’s name, native language, and interests are provided.
    Your primary goal is to assist the user with any questions he might have.
    **Assist the user in English. Do not use other languages.**

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
  GeneralAgent({
    this.userID,
  }) {
    promptTemplate = ChatPromptTemplate.fromTemplates([
      (ChatMessageType.system, generalAgentSystemPrompt),
      (ChatMessageType.messagesPlaceholder, 'message_history'),
      (ChatMessageType.human, '{question}'),
    ]);
    final agent = ToolsAgent.fromLLMAndTools(
        llm: chatModel,
        tools: [],
        systemChatMessage: SystemChatMessagePromptTemplate.fromTemplate(
            generalAgentSystemPrompt),
        extraPromptMessages: [
          ChatMessagePromptTemplate.messagesPlaceholder('message_history'),
        ]);

    executor = AgentExecutorWithNextStepCallback(
      agent: agent,
      toolUsageCallback: (String a) {},
    );
  }

  // Greet method. Used to start the conversation
  Future<String> greet(
      List<Map<String, dynamic>> messageHistory, String userInformation) async {
    String response = "";
    final prompt = PromptValue.chat([
      ChatMessage.system(
          "Use English. Information about the user: $userInformation"),
      ChatMessage.humanText(
          "Start the conversation by greeting me and asking me what brings me here today without acknowledging that I asked you to.")
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
