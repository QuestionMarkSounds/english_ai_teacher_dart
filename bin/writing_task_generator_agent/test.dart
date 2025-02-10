import 'dart:io';
import 'misc.dart';
import 'writing_task_generator_agent.dart';

void main() async {
  int index = 0;
  for (String key in systemPrompts.keys) {
    print('$index: $key');
    index++;
  }

  stdout.write('Enter the index of the prompt: ');
  String? promptIndexStr = stdin.readLineSync();
  int? promptIndex = int.tryParse(promptIndexStr ?? '');

  String key = systemPrompts.keys.elementAt(promptIndex ?? 0);
  Map<String, dynamic> selectedEntry = systemPrompts[key] ?? {};
  print(
      "Selected prompt: ${key}\n\n Description: ${selectedEntry['howItWorks']}\n\n Objective: ${selectedEntry['objective'] ?? ''}\n\n Variations: ${selectedEntry['variations'] ?? ''}");

  index = 0;
  for (String englishLevel in englishLevels) {
    print('$index: $englishLevel');
    index++;
  }

  stdout.write('Enter the index of the prompt: ');
  String? englishLevelIndexStr = stdin.readLineSync();
  int? englishLevelIndex = int.tryParse(englishLevelIndexStr ?? '');

  String englishLevel = englishLevels.elementAt(englishLevelIndex ?? 0);

  print("Selected english level: ${englishLevel}");

  stdout.write('Enter the topic: ');
  String? topic = stdin.readLineSync();

  print("Generating writing task...");

  var result = await runWritingTaskGeneratorAgent(
    userId: 'user2',
    filePath: 'memory.json',
    chatModel: chatModel,
    taskName: key,
    taskDescription: selectedEntry['howItWorks'],
    taskObjective: selectedEntry['objective'] ?? '',
    taskVariations: selectedEntry['variations'] ?? '',
    englishLevel: englishLevel,
    topic: topic,
  );
  print("AI output: \n ${result["output"][0].arguments["exercise"]}");
}
