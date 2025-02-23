import 'package:langchain_openai/langchain_openai.dart';
import 'package:dotenv/dotenv.dart';

// Initializing the chat model.
var env = DotEnv()..load();
ChatOpenAI chatModel = ChatOpenAI(
  apiKey: env["OPENAI_API_KEY"],
  defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"),
);
