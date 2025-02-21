import 'onboarding_agent.dart';
import 'package:dotenv/dotenv.dart';
import 'package:langchain_openai/langchain_openai.dart';

// ------------------------
// Predefined input section
// ------------------------

// User ID
const userId = "benny";

// User info
const userInfo = {
  "Name": "Benny",
  "Native Language": "Danish",
  "Interests": "Watching TV, Politics",
};

// Chat history
const chatHistory = [
  {"assistant": "Hello, Benny! Why do you want to learn English?"},
  {"user": "i want job"},
  {
    "assistant":
        "You want to learn English for a job. Is that correct? Can you tell me more about what kind of job you want?"
  },
  {"user": "i want uber driver amerija"},
  {
    "assistant":
        "You want to learn English to become an Uber driver in America. Is that right?"
  },
];

// User prompt
const userPrompt = "correct";

// ----------------------------
// Agent initialization section
// ----------------------------

// Initialization of the chat model.
var env = DotEnv()..load();
final chatModel = ChatOpenAI(
    apiKey: env["OPENAI_API_KEY"],
    defaultOptions: ChatOpenAIOptions(model: "gpt-4o-mini"));

// Initialization of the onboarding agent.
OnboardingAgent onboardingAgent = OnboardingAgent(
    llm: chatModel,
    updateUserCallback: (Map<String, dynamic> output) {
      updateUser(output);
    },
    generatePlanCallback: (Map<String, dynamic> output) {
      savePlan(output);
    },
    toolUsageCallback: (tool) => print("\n\nABOUT TO USE TOOL: $tool"));

// -------------------------------------
// Example of using the onboarding agent
// -------------------------------------

// Example of using the onboarding agent with predefined inputs.
void main() async {
  String response = await onboardingAgent.stream(
      userPrompt, chatHistory, userInfo.toString());

  saveAIResponse(response);
}

// --------------------------
// Callback functions section
// --------------------------

updateUser(userInfo) {
  // Redefine the logic to commit to firebase user info.
  print("\n\nUPDATE USER TOOL\n\n $userInfo");
}

savePlan(plan) {
  // Redefine the logic to adjust frontend to show spinner, and commit plan to firebase.
  print("\n\nSAVE PLAN TOOL\n\n $plan");
}

saveAIResponse(response) {
  // Redefine the logic to commit to firebase chat history.
  print("\nAI: $response");
}
