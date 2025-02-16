import 'dart:io';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:convert';
import 'json_memory_manager.dart';
import 'package:dotenv/dotenv.dart';
import 'onboarding_agent/onboarding_agent.dart';

var env = DotEnv()..load();
final chatModel = ChatOpenAI(
    apiKey: env["OPENAI_API_KEY"],
    defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"));

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

// -----------------------
// MEMORY SECTION
// -----------------------

final memoryLlm = ConversationBufferMemory(returnMessages: true);
File memoryFile = File('memory.json');
late JsonMemoryManager memoryManager;

final memoryJson = [];

File userInfoFile = File('user_info.json');
File learningPlanFile = File('learning_plan.json');

void main() async {
  OnboardingAgent onboardingAgent = await createOnboardingAgent(
      userId: "q", filePath: memoryFile.path, chatModel: chatModel);

  String response = await onboardingAgent.invoke(
      "Start the conversation by greeting me and asking me why I want to learn english without acknowledging that I asked you to.");

  print('AI: ${response}');

  while (true) {
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    if (userInput == null || userInput.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    String response = await onboardingAgent.invoke(userInput);

    print('AI: ${response}');
  }
}
