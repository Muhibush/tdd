import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia useCase;
  late MockNumberTriviaRepository repository;
  const tNumber = 1;
  var tNumberTrivia = const NumberTrivia(number: 1, text: 'text');

  setUpAll(() {
    repository = MockNumberTriviaRepository();
    useCase = GetConcreteNumberTrivia(repository);
  });

  test('get trivia number', () async {
    when(() => repository.getConcreteNumberTrivia(any()))
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await useCase(const Params(number: tNumber));

    expect(result, Right(tNumberTrivia));
    verify(() => repository.getConcreteNumberTrivia(tNumber)).called(1);
    verifyNoMoreInteractions(repository);
  });
}
