import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd/core/usecase/usecase.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetRandomNumberTrivia useCase;
  late MockNumberTriviaRepository repository;
  var tNumberTrivia = const NumberTrivia(number: 1, text: 'text');

  setUpAll(() {
    repository = MockNumberTriviaRepository();
    useCase = GetRandomNumberTrivia(repository);
  });

  test('get trivia number', () async {
    when(() => repository.getRandomNumberTrivia())
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await useCase(NoParams());

    expect(result, Right(tNumberTrivia));
    verify(() => repository.getRandomNumberTrivia()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
