import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd/core/error/failure.dart';
import 'package:tdd/core/usecase/usecase.dart';
import 'package:tdd/core/util/input_converter.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd/feature/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class MockParams extends Fake implements Params {}

void main() {
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;
  late NumberTriviaBloc bloc;

  setUpAll(() {
    registerFallbackValue(MockParams());
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
    reset(mockGetRandomNumberTrivia);
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

    void setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(tNumberParsed));

    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
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
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
        // assert later
        final expected = [
          const Error(invalidInputFailureMessage),
        ];
        expectLater(bloc.stream, emitsInOrder(expected));
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
      },
    );
    test(
      'should get data from the concrete use case',
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(const GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(() => mockGetConcreteNumberTrivia(any()));
        // assert
        verify(
            () => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );
    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      //assert later
      final expected = [Loading(), const Loaded(tNumberTrivia)];
      expectLater(bloc, emitsInOrder(expected));
      //act
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
    test('should emit [Loading, Error] when getting data fails', () async* {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      final expected = [
        Loading(),
        const Error(serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async* {
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      final expected = [
        Loading(),
        const Error(cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    // NumberTrivia instance is needed too, of course
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async* {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(tNumberTrivia));
        // act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(() => mockGetRandomNumberTrivia(any()));
        // assert
        verify(() => mockGetRandomNumberTrivia(NoParams()));
      },
    );
    test('should emits [Loading, Loaded] when data is gotten successfully',
        () async* {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      //assert later
      final expected = [Loading(), const Loaded(tNumberTrivia)];
      expectLater(bloc, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
    });
    test('should emit [Loading, Error] when getting data fails', () async* {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      final expected = [
        Loading(),
        const Error(serverFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(GetTriviaForRandomNumber());
    });
    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async* {
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      final expected = [
        Loading(),
        const Error(cacheFailureMessage),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
