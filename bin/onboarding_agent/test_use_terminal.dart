import 'onboarding_agent.dart';
import 'package:dotenv/dotenv.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'dart:io';
import 'dart:convert';

// ------------------------
// Predefined input section
// ------------------------

// User ID
const userId = "benny";

// User info
const userInfo = {
  "Name": "Benny",
  "Native Language": "Danish",
  "Interests": "Watching TV, Politics",
};

JsonEncoder encoder = JsonEncoder.withIndent('  ');

File memoryFile = File('jsons/memory.json');
File userInfoFile = File('jsons/user_info.json');
File learningPlanFile = File('jsons/learning_plan.json');

Map<String, dynamic> memoryJson = {};
Map<String, dynamic> userInfoJson = {};
Map<String, dynamic> learningPlanJson = {};

void initJsons() {
  if (!memoryFile.existsSync()) {
    memoryFile.writeAsStringSync(json.encode({}));
  }

  if (!userInfoFile.existsSync()) {
    userInfoFile.writeAsStringSync(json.encode({}));
  }

  if (!learningPlanFile.existsSync()) {
    learningPlanFile.writeAsStringSync(json.encode({}));
  }

  memoryJson = json.decode(memoryFile.readAsStringSync());
  userInfoJson = json.decode(userInfoFile.readAsStringSync());
  learningPlanJson = json.decode(learningPlanFile.readAsStringSync());

  if (!userInfoJson.containsKey(userId)) {
    userInfoJson[userId] = userInfo;
  }

  if (!learningPlanJson.containsKey(userId)) {
    learningPlanJson[userId] = {};
  }

  if (!memoryJson.containsKey(userId)) {
    memoryJson[userId] = [];
  }

  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
  userInfoFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(userInfoJson));
  learningPlanFile.writeAsStringSync(
      JsonEncoder.withIndent('  ').convert(learningPlanJson));
}

// ----------------------------
// Agent initialization section
// ----------------------------

// Initialization of the chat model.
var env = DotEnv()..load();
final chatModel = ChatOpenAI(
    apiKey: env["OPENAI_API_KEY"],
    defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"));

// Initialization of the onboarding agent.
OnboardingAgent onboardingAgent = OnboardingAgent(
    llm: chatModel,
    updateUserCallback: (Map<String, dynamic> output) {
      updateUser(output);
    },
    generatePlanCallback: (Map<String, dynamic> output) {
      savePlan(output);
    },
    toolUsageCallback: (tool) => print("\n\nABOUT TO USE TOOL: $tool"));

// -------------------------------------
// Example of using the onboarding agent
// -------------------------------------

// Example of using the onboarding agent with predefined inputs.
void main() async {
  initJsons();

  while (true) {
    stdout.write('You: ');
    String? userPrompt = stdin.readLineSync();

    if (userPrompt == null) {
      break;
    }

    saveUserInput(userPrompt);

    List<Map<String, dynamic>> chatHistory =
        (memoryJson[userId] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    String response = await onboardingAgent.stream(
        userPrompt, chatHistory, userInfo.toString());

    print("AI: $response");
    saveAIResponse(response);
  }
}

// --------------------------
// Callback functions section
// --------------------------

updateUser(userInfo) {
  userInfoJson[userId] = userInfo;
  userInfoFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(userInfoJson));
}

savePlan(plan) {
  learningPlanJson[userId] = plan;
  learningPlanFile.writeAsStringSync(
      JsonEncoder.withIndent('  ').convert(learningPlanJson));
}

saveAIResponse(response) {
  memoryJson[userId].add({"assistant": response});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}

saveUserInput(userPrompt) {
  memoryJson[userId].add({"user": userPrompt});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}
