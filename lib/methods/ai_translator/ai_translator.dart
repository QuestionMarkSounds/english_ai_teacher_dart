import 'package:langchain/langchain.dart';

import '../../src/globals.dart';

Future<String> aiTranslate(
    {required String text,
    required String langOut,
    String langIn = "unknown"}) async {
  final promptTemplate = ChatPromptTemplate.fromTemplates(
    [
      (
        ChatMessageType.system,
        """
        Translate the following text from $langIn to $langOut: 
        
        $text
        """
      )
    ],
  );
  final LLMChain chain = LLMChain(llm: chatModel, prompt: promptTemplate);
  var result = await chain.invoke({});
  return result["output"].content;
}
