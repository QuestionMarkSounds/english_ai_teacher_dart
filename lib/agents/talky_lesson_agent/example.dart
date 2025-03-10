import 'talky_lesson_agent.dart';
import 'dart:io';

// Example of using the talky agent with predefined inputs.
void main() async {
  // ------------------------
  // Predefined input section
  // ------------------------

  // How many rounds to play
  int maxRounds = 3;

  // User info
  Map<String, dynamic> userInfo = {
    "name": "Mukhtar",
    "native language": "Armenian",
    "interests": "Watching TV, Politics",
    "current level of english": "A2",
  };

  // Chat history
  List<Map<String, dynamic>> messageHistory = [];

  // ----------------------------
  // Agent initialization section
  // ----------------------------
  bool lessonComplete = false;

  String lessonSystemPrompt =
      "Create open-ended questions about the importance of knowing how to find places in a foreign country. Ask Mukhtar what he thinks are the most essential places to locate while traveling.";
  TalkyLessonAgent agent = TalkyLessonAgent(
      proficiencyLevel: userInfo["current level of english"],
      lessonSystemPrompt: lessonSystemPrompt,
      maxIterations: maxRounds,
      lessonCompleteCallback: (Map<String, dynamic> response) {
        lessonComplete = true;
        print("Lesson complete:\n\n ${response}");
      });

  // --------------------------------
  // Example of using the talky agent
  // --------------------------------

  String response = await agent.greet(messageHistory, userInfo.toString());
  askQuestion(response);
  messageHistory.add({"assistant": response});

  while (!lessonComplete) {
    // The flow starts with the agent asking a question

    if (lessonComplete) break;

    // The user responds
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    // Stop the flow if user input is null
    if (userInput == null) {
      break;
    }

    // The agent responds with an improvement suggestion
    String replyResponse =
        await agent.stream(userInput, messageHistory, userInfo.toString());
    replyWithImprovement(replyResponse);
    messageHistory.add({"user": userInput});
    messageHistory.add({"assistant": replyResponse});
  }
}

// --------------------------
// Callback functions section
// --------------------------

askQuestion(response) {
  // Redefine the logic to commit to firebase user info.
  print("\nAI Question: ${response}");
}

replyWithImprovement(response) {
  // Redefine the logic to adjust frontend to show spinner, and commit plan to firebase.
  print('\nAI Reply: ${response}');
}
