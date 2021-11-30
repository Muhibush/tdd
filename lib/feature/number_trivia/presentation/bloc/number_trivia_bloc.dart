import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tdd/core/util/input_converter.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String serverFailureMessage = 'Server Failure';
const String cacheFailureMessage = 'Cache Failure';
const String invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

// / TODO handle debounce
class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(Empty()) {
    on<GetTriviaForConcreteNumber>(_onGetTriviaForConcreteNumber);
  }

  void _onGetTriviaForConcreteNumber(
      GetTriviaForConcreteNumber event, Emitter<NumberTriviaState> emit) async {
    final inputEither =
        inputConverter.stringToUnsignedInteger(event.numberString);
    inputEither.fold(
      (l) => emit(const Error(invalidInputFailureMessage)),
      (number) {
        getConcreteNumberTrivia(Params(number: number));
      },
    );
  }
}
