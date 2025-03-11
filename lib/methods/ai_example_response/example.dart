import 'ai_example_response.dart';

final history = [
  {
    "assistant":
        "Hello, Benny! How are you today? What inspired your interest in learning English?"
  },
  {"user": "I want to travel to US"},
  {
    "assistant":
        "Great! What exactly do you need English for when you travel? For example, do you want to meet new people or understand signs?"
  },
  {"user": "i want to see gran canyons I want to read signs"},
  {
    "assistant":
        "Awesome! So, you want to read signs and understand information during your visit. What specific skill do you want to improve? For example, are you more focused on speaking and listening, or do you want to practice reading?"
  }
];

void main() async {
  var stopwatch = Stopwatch()..start();
  var result = await aiExampleResponse(
      messageHistory: history, langOut: "english", proficiencyLevel: "A1");
  stopwatch.stop();
  print('Elapsed time: ${stopwatch.elapsedMilliseconds} ms');
  print(result);
}
