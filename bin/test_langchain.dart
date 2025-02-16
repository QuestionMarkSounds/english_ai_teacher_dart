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

final memoryJson = json.decode(memoryFile.readAsStringSync());

File userInfoFile = File('user_info.json');
File learningPlanFile = File('learning_plan.json');

void main() async {
  OnboardingAgent onboardingAgent = OnboardingAgent(
      llm: chatModel,
      updateUserCallback: (Map<String, dynamic> output) {
        print("Upd user\n $output");
      },
      generatePlanCallback: (Map<String, dynamic> output) {
        print("Gen plan\n $output");
      },
      toolUsageCallback: (tool) => print("BOUTA USE TOOL $tool"));

  // String response = await onboardingAgent.invoke(
  //     "Start the conversation by greeting me and asking me why I want to learn english without acknowledging that I asked you to.");

  // print('AI: ${response}');

  while (true) {
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    if (userInput == null || userInput.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }
    List<Map<String, dynamic>> memoryInput = [];

    for (var i in memoryJson["user1"]) {
      memoryInput.add(i);
    }
    String response = await onboardingAgent.stream(userInput, memoryInput,
        userInfo("Mukhtar", "Armenian", "Watching TV, Politics"));

    print('AI: ${response}');
  }
}
