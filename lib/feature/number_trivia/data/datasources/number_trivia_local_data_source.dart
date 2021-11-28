import 'package:tdd/feature/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  Future<NumberTriviaModel> getLastNumberTrivia(int number);

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}
