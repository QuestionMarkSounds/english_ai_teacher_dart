import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'package:langchain/langchain.dart';

JsonEncoder encoder =
    JsonEncoder.withIndent('  '); // '  ' for 2-space indentation

class BaseMemoryManagerTemplate {
  String? roomId;
  String? memoryFilePath;
  final String userId;

  BaseMemoryManagerTemplate(
      {required this.userId, this.memoryFilePath, this.roomId});
}

final class BaseUserInfoChatMemory extends BaseChatMemory {
  String? roomId;
  final String? memoryFilePath;
  final String userId;
  BaseUserInfoChatMemory(this.userId,
      {this.memoryFilePath,
      super.inputKey,
      super.outputKey,
      super.returnMessages = true,
      required super.chatHistory});

  @override
  Future<MemoryVariables> loadMemoryVariables(
      [MemoryInputValues values = const {}]) {
    // TODO: implement loadMemoryVariables
    throw UnimplementedError();
  }

  @override
  // TODO: implement memoryKeys
  Set<String> get memoryKeys => throw UnimplementedError();

  Future<void> save() async {}
}

final class JsonMemoryManager extends BaseUserInfoChatMemory {
  String? roomId;
  final String memoryFilePath;
  final String userId;
  final File memoryFile;

  static Future<JsonMemoryManager> create({
    required String memoryFilePath,
    required String systemPrompt,
    required String userId,
    String? roomId,
    int? maxMessages,
  }) async {
    final memoryFile = File(memoryFilePath);
    final chatHistory = await _load(memoryFile, userId, systemPrompt);
    return JsonMemoryManager._(
      memoryFilePath: memoryFilePath,
      userId: userId,
      roomId: roomId,
      memoryFile: memoryFile,
      chatHistory: chatHistory,
    );
  }

  /// {@macro conversation_buffer_memory}
  JsonMemoryManager._({
    final BaseChatMessageHistory? chatHistory,
    super.inputKey,
    super.outputKey,
    super.returnMessages = true,
    required this.memoryFilePath,
    required this.userId,
    this.roomId,
    required this.memoryFile,
    this.memoryKey = BaseMemory.defaultMemoryKey,
    this.systemPrefix = SystemChatMessage.defaultPrefix,
    this.humanPrefix = HumanChatMessage.defaultPrefix,
    this.aiPrefix = AIChatMessage.defaultPrefix,
    this.toolPrefix = ToolChatMessage.defaultPrefix,
  }) : super(userId, chatHistory: chatHistory ?? ChatMessageHistory());

  /// The memory key to use for the chat history.
  /// This will be passed as input variable to the prompt.
  final String memoryKey;

  /// The prefix to use for system messages if [returnMessages] is false.
  final String systemPrefix;

  /// The prefix to use for human messages if [returnMessages] is false.
  final String humanPrefix;

  /// The prefix to use for AI messages if [returnMessages] is false.
  final String aiPrefix;

  /// The prefix to use for tool messages if [returnMessages] is false.
  final String toolPrefix;

  static Future<BaseChatMessageHistory> _load(
      File memoryFile, String userId, String systemPrompt) async {
    BaseChatMessageHistory chatHistory = ChatMessageHistory();
    chatHistory.addChatMessage(ChatMessage.system(systemPrompt));
    Map<String, dynamic> memory = jsonDecode(await memoryFile.readAsString());
    if (memory.containsKey(userId)) {
      List<dynamic> userMessages = memory[userId];
      for (var message in userMessages) {
        if (message is Map<String, dynamic>) {
          switch (message.keys.first) {
            case 'user':
              chatHistory.addHumanChatMessage(message.values.first);
              break;
            case 'assistant':
              chatHistory.addAIChatMessage(message.values.first);
              break;
          }
        }
      }
    }
    return chatHistory;
  }

  Future<void> addMessage(Map<String, String> message) async {
    switch (message.keys.first) {
      case 'user':
        chatHistory.addHumanChatMessage(message.values.first);
        break;
      case 'assistant':
        if (message.values.first.isNotEmpty) {
          chatHistory.addAIChatMessage(message.values.first);
        }
        break;
    }
    await save();
  }

  @override
  Future<void> save() async {
    Map<String, dynamic> memory = jsonDecode(await memoryFile.readAsString());
    List<Map<String, dynamic>> messages = [];
    List<ChatMessage> chatMessages = await chatHistory.getChatMessages();
    for (ChatMessage chatMessage in chatMessages) {
      switch (chatMessage.runtimeType) {
        case HumanChatMessage:
          messages.add(
              {'user': chatMessage.contentAsString.replaceAll("Human: ", "")});
          break;
        case AIChatMessage:
          if (chatMessage.contentAsString.isNotEmpty) {
            messages.add({'assistant': chatMessage.contentAsString});
          }
          break;
      }
    }
    memory[userId] = messages;
    await memoryFile.writeAsString(encoder.convert(memory));
  }

  @override
  Future<MemoryVariables> loadMemoryVariables([
    final MemoryInputValues values = const {},
  ]) async {
    final messages = await chatHistory.getChatMessages();
    if (returnMessages) {
      return {memoryKey: messages};
    }
    return {
      memoryKey: messages.toBufferString(
        systemPrefix: systemPrefix,
        humanPrefix: humanPrefix,
        aiPrefix: aiPrefix,
        toolPrefix: toolPrefix,
      ),
    };
  }

  @override
  Set<String> get memoryKeys => {memoryKey};
}

void main() async {
  final memoryManager = await JsonMemoryManager.create(
      memoryFilePath: 'memory.json',
      userId: 'user2',
      systemPrompt: "Reply to everything in the rudest possible way");
  await memoryManager.addMessage({"user": "assalamualaikum 2.0"});
}
