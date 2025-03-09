import 'talky_lesson_agent.dart';
import 'dart:io';

// Example of using the talky agent with predefined inputs.
void main() async {
  // ------------------------
  // Predefined input section
  // ------------------------

  // How many rounds to play
  int maxRounds = 7;

  // User info
  Map<String, dynamic> userInfo = {
    "name": "Mukhtar",
    "native language": "Russian",
    "interests": "Watching TV, Politics",
    "current level of english": "A1",
  };

  // Chat history
  List<Map<String, dynamic>> messageHistory = [];

  // ----------------------------
  // Agent initialization section
  // ----------------------------
  bool lessonComplete = false;

  String lessonSystemPrompt =
      "Teach Mukhtar some basic vocabulary for travelling in a foreign country. Keep in mind that Mukhtar language only starts learning the languag, so try to talk to him in both lesson language and his native language.";
  TalkyLessonAgent agent = TalkyLessonAgent(
      proficiencyLevel: userInfo["current level of english"],
      lessonSystemPrompt: lessonSystemPrompt,
      maxIterations: maxRounds,
      language: "French",
      nativeLanguage: userInfo["native language"],
      teachInNativeLanguage: true,
      lessonCompleteCallback: (Map<String, dynamic> response) {
        lessonComplete = true;
        print("Lesson complete:\n\n ${response}");
      });

  // --------------------------------
  // Example of using the talky agent
  // --------------------------------
  while (!lessonComplete) {
    // The flow starts with the agent asking a question
    Map<String, dynamic> response =
        await agent.askQuestion(messageHistory, userInfo);
    askQuestion(response);
    messageHistory.add(response);

    if (lessonComplete) break;

    // The user responds
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    // Stop the flow if user input is null
    if (userInput == null) {
      break;
    }

    // The agent responds with an improvement suggestion
    List<Map<String, dynamic>> replyResponse =
        await agent.replyWithImprovement(userInput, messageHistory, userInfo);
    replyWithImprovement(replyResponse);
    messageHistory.add({"user": userInput});
    messageHistory.addAll(replyResponse);
  }
}

// --------------------------
// Callback functions section
// --------------------------

askQuestion(response) {
  // Redefine the logic to commit to firebase user info.
  print("\nAI Question: ${response['assistant']}");
}

replyWithImprovement(response) {
  // Redefine the logic to adjust frontend to show spinner, and commit plan to firebase.
  for (var message in response) {
    if (message.keys.first == 'assistant') {
      print('\nAI Reply: ${message.values.first}');
    }
  }
}
