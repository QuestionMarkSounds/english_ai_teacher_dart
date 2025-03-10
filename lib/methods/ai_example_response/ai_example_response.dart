import 'package:english_ai_teacher/src/helper.dart';
import 'package:langchain/langchain.dart';

import '../../src/globals.dart';

Future<String> aiExampleResponse(
    {required List<Map<String, dynamic>> messageHistory,
    String langOut = "English",
    String proficiencyLevel = "A1"}) async {
  final messages = processMessageHistorySwappedRoles(messageHistory);
  final promptTemplate = ChatPromptTemplate.fromTemplates(
    [
      (
        ChatMessageType.system,
        """
        Your role is user.
        Create an response to the following conversation using the $langOut language and the $proficiencyLevel proficiency level:


        """
      ),
      (ChatMessageType.messagesPlaceholder, 'messageHistory'),
    ],
  );
  final LLMChain chain = LLMChain(llm: chatModel, prompt: promptTemplate);
  var result = await chain.invoke({'messageHistory': messages});
  return result["output"].content;
}
