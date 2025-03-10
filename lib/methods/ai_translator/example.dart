import 'ai_translator.dart';

void main() async {
  var stopwatch = Stopwatch()..start();
  var result = await aiTranslate(
      text:
          "Bonjour Mukhtar! Aujourd'hui, nous allons apprendre des mots de base pour voyager dans un pays étranger. Prêt?",
      langOut: "russian");
  stopwatch.stop();
  print('Elapsed time: ${stopwatch.elapsedMilliseconds} ms');
  print(result);

  stopwatch = Stopwatch()..start();
  result = await aiTranslate(
      text:
          "La phrase que j'ai dite signifie que nous allons parler de l'importance de trouver des lieux dans un pays étranger. Je te demande aussi ce que tu penses des endroits importants à connaître en voyage.",
      langOut: "russian");
  stopwatch.stop();
  print('Elapsed time: ${stopwatch.elapsedMilliseconds} ms');
  print(result);
}
