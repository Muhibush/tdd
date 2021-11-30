import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd/core/util/input_converter.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd/feature/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUpAll(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  tearDown(() {
    reset(mockGetConcreteNumberTrivia);
    reset(mockGetConcreteNumberTrivia);
    reset(mockInputConverter);
  });

  test('initialState should be Empty', () {
    expect(bloc.state, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    const tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(
            () => mockInputConverter.stringToUnsignedInteger(any()));
        // assert
        verify(() => mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );
    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        // assert later
        final expected = [
          const Error(invalidInputFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
  });
}
