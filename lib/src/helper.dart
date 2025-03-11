import 'dart:convert';

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

List<ChatMessage> processMessageHistorySwappedRoles(
    List<Map<String, dynamic>> messageHistory) {
  List<ChatMessage> messages = [];
  for (Map<String, dynamic> message in messageHistory) {
    switch (message.keys.first) {
      case 'user':
        messages.add(ChatMessage.ai(message.values.first));
        break;
      case 'assistant':
        messages.add(ChatMessage.humanText(message.values.first));
        break;
    }
  }
  return messages;
}

int countHumanMessagesInHistory(List<Map<String, dynamic>> messageHistory) {
  int count = 0;
  for (Map<String, dynamic> message in messageHistory) {
    if (message.keys.first == 'user') {
      count++;
    }
  }
  return count;
}

ChatMessage getLatestUserMessage(List<ChatMessage> messageHistory) {
  List<ChatMessage> messageHistoryReversed = messageHistory.reversed.toList();
  for (int i = 0; i < messageHistory.length; i++) {
    if (messageHistoryReversed[i] is HumanChatMessage) {
      messageHistory.removeAt(messageHistory.length - 1 - i);
      return messageHistoryReversed[i];
    }
  }
  return ChatMessage.humanText('');
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

JsonEncoder encoder = JsonEncoder.withIndent('  ');
