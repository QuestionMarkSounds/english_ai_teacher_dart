import 'talky_lesson_agent.dart';
import 'dart:io';

// Example of using the talky agent with predefined inputs.
void main() async {
  // ------------------------
  // Predefined input section
  // ------------------------

  // How many rounds to play
  int maxRounds = 5;

  // User info
  Map<String, dynamic> userInfo = {
    "name": "Mukhtar",
    "native language": "Armenian",
    "interests": "Watching TV, Politics"
  };

  // Chat history
  List<Map<String, dynamic>> messageHistory = [];

  // ----------------------------
  // Agent initialization section
  // ----------------------------

  TalkyLessonAgent agent =
      TalkyLessonAgent(proficiencyLevel: "A2", topic: "cars");

  // -------------------------------------
  // Example of using the talky agent
  // -------------------------------------
  int round = 0;
  while (round < maxRounds) {
    // The flow starts with the agent asking a question
    Map<String, dynamic> response =
        await agent.askQuestion(messageHistory, userInfo);
    askQuestion(response);
    messageHistory.add(response);

    // The user responds
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    // Stop the flow if user input is null
    if (userInput == null) {
      break;
    }

    messageHistory.add({"user": userInput});

    // The agent responds with an improvement suggestion
    List<Map<String, dynamic>> replyResponse =
        await agent.replyWithImprovement(userInput, messageHistory, userInfo);
    replyWithImprovement(replyResponse[1]["assistant"]);
    messageHistory.addAll(replyResponse);

    // Next round
    round++;
  }

  // The agent completes the lesson after the last round
  Map<String, dynamic> response =
      await agent.completeLesson(messageHistory, userInfo);
  completeLesson(response);
  messageHistory.add(response);
}

// --------------------------
// Callback functions section
// --------------------------

askQuestion(response) {
  // Redefine the logic to commit to firebase user info.
  print("\nAI Question: $response");
}

replyWithImprovement(response) {
  // Redefine the logic to adjust frontend to show spinner, and commit plan to firebase.
  print('\nAI Reply: $response');
}

completeLesson(response) {
  // Redefine the logic to commit to firebase chat history.
  print('\nAI Completion: $response');
}
