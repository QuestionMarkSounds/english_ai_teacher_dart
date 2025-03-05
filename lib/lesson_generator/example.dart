import 'dart:convert';

import 'lesson_generator.dart';

JsonEncoder encoder = JsonEncoder.withIndent('  ');

void main() async {
  List<dynamic> lessons = await generateLessons(
      exerciseType: "talky_lesson",
      planName: "English for Travel",
      goalName: "Basic Conversation Skills",
      subgoalName: "Asking for Directions",
      subgoalDuration: "1 week",
      userInfo: {
        "name": "Mukhtar",
        "native language": "Armenian",
        "english level": "A2"
      },
      numberOfLessons: 10);
  int index = 1;
  for (Map<String, dynamic> lesson in lessons) {
    print("----------------------\n\nLesson $index");
    print(JsonEncoder.withIndent('  ').convert(lesson));
    index++;
  }
}
