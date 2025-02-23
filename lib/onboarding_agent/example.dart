import 'onboarding_agent.dart';
import 'dart:convert';
import 'dart:io';

// ------------------------------------
// Initializing Jsons for local testing
// ------------------------------------

JsonEncoder encoder = JsonEncoder.withIndent('  ');

initJsons(userId, userInfo, memoryJson, userInfoJson, learningPlanJson,
    memoryFile, userInfoFile, learningPlanFile) {
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
    userInfoJson[userId] = userInfo; // Ensure userInfo is passed as a parameter
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

  return (memoryJson, userInfoJson, learningPlanJson);
}

// Example of using the onboarding agent with predefined inputs.
void main() async {
  // ------------------------
  // Predefined input section
  // ------------------------

  // User ID
  String userId = "benny";

  // User info
  Map<String, dynamic> userInfo = {
    "Name": "Benny",
    "Native Language": "Danish",
    "Interests": "Watching TV, Politics",
  };

  // -------------------------------------------------------------
  // Json initialization. Not needed in prod, use firebase instead
  // -------------------------------------------------------------
  Map<String, dynamic> memoryJson = {};
  Map<String, dynamic> userInfoJson = {};
  Map<String, dynamic> learningPlanJson = {};

  File memoryFile = File('lib/onboarding_agent/jsons/memory.json');
  File userInfoFile = File('lib/onboarding_agent/jsons/user_info.json');
  File learningPlanFile = File('lib/onboarding_agent/jsons/learning_plan.json');

  (memoryJson, userInfoJson, learningPlanJson) = initJsons(
      userId,
      userInfo,
      memoryJson,
      userInfoJson,
      learningPlanJson,
      memoryFile,
      userInfoFile,
      learningPlanFile);

  // ----------------------------
  // Agent initialization section
  // ----------------------------

  // Initialization of the onboarding agent.
  OnboardingAgent onboardingAgent = OnboardingAgent(
      updateUserCallback: (Map<String, dynamic> output) {
        updateUser(userInfoJson, userInfoFile, userId, output);
      },
      generatePlanCallback: (Map<String, dynamic> output) {
        savePlan(learningPlanJson, learningPlanFile, userId, output);
      },
      toolUsageCallback: (tool) => print("\n\nABOUT TO USE TOOL: $tool"));

  // -------------------------------------
  // Example of using the onboarding agent
  // -------------------------------------
  while (true) {
    // User input
    stdout.write('You: ');
    String? userPrompt = stdin.readLineSync();

    // Stop the flow if user input is null
    if (userPrompt == null) {
      break;
    }

    saveUserInput(memoryJson, memoryFile, userId, userPrompt);

    List<Map<String, dynamic>> messageHistory =
        (memoryJson[userId] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    // AI response
    String response = await onboardingAgent.stream(
        userPrompt, messageHistory, userInfo.toString());
    replyToUser(memoryJson, memoryFile, userId, response);
  }
}

// --------------------------
// Callback functions section
// --------------------------

updateUser(userInfoJson, userInfoFile, userId, userInfo) {
  // Redefine the logic to commit to firebase user info.
  userInfoJson[userId] = userInfo;
  userInfoFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(userInfoJson));
}

savePlan(learningPlanJson, learningPlanFile, userId, plan) {
  // Redefine the logic to commit to firebase learning plan.
  learningPlanJson[userId] = plan;
  learningPlanFile.writeAsStringSync(
      JsonEncoder.withIndent('  ').convert(learningPlanJson));
}

replyToUser(memoryJson, memoryFile, userId, response) {
  // Redefine the logic to commit to firebase chat history.
  print("AI: $response");
  memoryJson[userId].add({"assistant": response});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}

saveUserInput(memoryJson, memoryFile, userId, userPrompt) {
  // Redefine the logic to commit to firebase chat history.
  memoryJson[userId].add({"user": userPrompt});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}
