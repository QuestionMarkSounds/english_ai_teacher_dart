import 'dart:io';

import 'talky_lesson_agent.dart';

void main() async {
  int rounds = 0;
  int maxRounds = 5;
  TalkyLessonAgent agent =
      TalkyLessonAgent(llm: chatModel, proficiencyLevel: "A2", topic: "cars");

  List<Map<String, dynamic>> messageHistory = [];

  Map<String, dynamic> userInfo = {
    "name": "Mukhtar",
    "native language": "Armenian",
    "interests": "Watching TV, Politics"
  };
  while (rounds < maxRounds) {
    Map<String, dynamic> response =
        await agent.askQuestion(messageHistory, userInfo);
    print('AI: ${response["assistant"]}');
    messageHistory.add(response);
    stdout.write('You: ');
    String? userInput = stdin.readLineSync();
    messageHistory.add({"user": userInput});
    if (userInput == null || userInput.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    List<Map<String, dynamic>> replyResponse =
        await agent.replyToUser(userInput, messageHistory, userInfo);
    messageHistory.addAll(replyResponse);
    print('AI: ${replyResponse[1]["assistant"]}');
    rounds++;
  }

  Map<String, dynamic> response =
      await agent.completeLesson(messageHistory, userInfo);
  messageHistory.add(response);
  print('LESSON COMPLETED!\n\n$response');
}
