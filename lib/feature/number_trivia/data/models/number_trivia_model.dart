import 'dart:convert';

import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    required String text,
    required int number,
  }) : super(number: number, text: text);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> jsonRes) =>
      NumberTriviaModel(
        text: jsonRes['text'],
        number: (jsonRes['number'] as num).toInt(),
      );

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'text': text,
        'number': number,
      };
}
