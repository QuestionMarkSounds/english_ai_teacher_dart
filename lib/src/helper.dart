import 'package:langchain/langchain.dart';

List<ChatMessage> processMessageHistory(
    List<Map<String, dynamic>> messageHistory) {
  List<ChatMessage> messages = [];
  for (Map<String, dynamic> message in messageHistory) {
    switch (message.keys.first) {
      case 'user':
        messages.add(ChatMessage.humanText(message.values.first));
        break;
      case 'assistant':
        messages.add(ChatMessage.ai(message.values.first));
        break;
    }
  }
  return messages;
}

List<Map<String, dynamic>> convertToJsonMessageHistory(
    List<ChatMessage> messageHistory) {
  List<Map<String, dynamic>> messages = [];
  for (ChatMessage message in messageHistory) {
    if (message is AIChatMessage) {
      messages.add({"assistant": message.contentAsString});
    } else if (message is HumanChatMessage) {
      messages.add({"user": message.contentAsString});
    }
  }
  return messages;
}
