import 'general_agent.dart';
import 'dart:convert';
import 'dart:io';

// ------------------------------------
// Initializing Jsons for local testing
// ------------------------------------

JsonEncoder encoder = JsonEncoder.withIndent('  ');

initJsons(
    userId, userInfo, memoryJson, userInfoJson, memoryFile, userInfoFile) {
  if (!memoryFile.existsSync()) {
    memoryFile.writeAsStringSync(json.encode({}));
  }

  if (!userInfoFile.existsSync()) {
    userInfoFile.writeAsStringSync(json.encode({}));
  }
  memoryJson = json.decode(memoryFile.readAsStringSync());
  userInfoJson = json.decode(userInfoFile.readAsStringSync());

  userInfoJson[userId] = userInfo;
  memoryJson[userId] = [];

  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
  userInfoFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(userInfoJson));

  return (memoryJson, userInfoJson);
}

// Example of using the general agent with predefined inputs
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

  File memoryFile = File('lib/agents/general_agent/jsons/memory.json');
  File userInfoFile = File('lib/agents/general_agent/jsons/user_info.json');

  (memoryJson, userInfoJson) = initJsons(
      userId, userInfo, memoryJson, userInfoJson, memoryFile, userInfoFile);

  // ----------------------------
  // Agent initialization section
  // ----------------------------

  // Initialization of the general agent
  GeneralAgent generalAgent = GeneralAgent();

  // -------------------------------------
  // Example of using the general agent
  // -------------------------------------

  List<Map<String, dynamic>> messageHistory =
      (memoryJson[userId] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();

  String response =
      await generalAgent.greet(messageHistory, userInfo.toString());
  replyToUser(memoryJson, memoryFile, userId, response);

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
    String response = await generalAgent.stream(
        userPrompt, messageHistory, userInfo.toString());
    replyToUser(memoryJson, memoryFile, userId, response);
  }
}

// --------------------------
// Callback functions section
// --------------------------

replyToUser(memoryJson, memoryFile, userId, response) {
  // Redefine the logic to commit to firebase chat history
  print("AI: $response");
  memoryJson[userId].add({"assistant": response});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}

saveUserInput(memoryJson, memoryFile, userId, userPrompt) {
  // Redefine the logic to commit to firebase chat history
  memoryJson[userId].add({"user": userPrompt});
  memoryFile
      .writeAsStringSync(JsonEncoder.withIndent('  ').convert(memoryJson));
}
