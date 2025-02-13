import 'dart:io';

import 'talky_lesson_agent.dart';

void main() async {
  int rounds = 0;
  int maxRounds = 5;
  TalkyLessonAgent agent =
      TalkyLessonAgent(llm: chatModel, proficiencyLevel: "A2");
  while (rounds < maxRounds) {
    String response = await agent.askQuestion();
    print('AI: ${response}');

    stdout.write('You: ');
    String? userInput = stdin.readLineSync();

    if (userInput == null || userInput.toLowerCase() == 'exit') {
      print('Goodbye!');
      break;
    }

    response = await agent.replyToUser(userInput);
    print('AI: ${response}');
    rounds++;
  }

  String response = await agent.completeLesson();
  print('LESSON COMPLETED!\n\n$response');
}
