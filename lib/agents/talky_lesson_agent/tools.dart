import 'package:langchain/langchain.dart';
import 'json_schemas.dart';

import '../../src/helper.dart';

final class CompleteLesson
    extends Tool<Map<String, dynamic>, ToolOptions, String> {
  final void Function(Map<String, dynamic> output) callback;
  final bool trackVocabulary;
  CompleteLesson({required this.callback, this.trackVocabulary = false})
      : super(
          name: 'completeLesson',
          description: """
              Use compose a summary upon the lesson completion.
              """,
          inputJsonSchema: trackVocabulary
              ? completeLessonToolVocabularySchema
              : completeLessonToolSchema,
          returnDirect: true,
        );
  @override
  Future<String> invokeInternal(
    final Map<String, dynamic> toolInput, {
    final ToolOptions? options,
  }) async {
    try {
      final String output =
          encoder.convert(toolInput); // Return the plan as output
      callback(toolInput);
      return output;
    } catch (e) {
      return "I don't know how to generate a plan.";
    }
  }

  @override
  Map<String, dynamic> getInputFromJson(final Map<String, dynamic> json) {
    // This method is responsible for parsing the JSON input into the expected Map type
    return json; // Returning the whole json as is (you can add more custom deserialization if needed)
  }
}
