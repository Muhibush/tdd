import 'dart:convert';

import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    required int number,
    required String text,
  }) : super(number: number, text: text);

  factory NumberTriviaModel.fromJson(Map<String, dynamic> jsonRes) =>
      NumberTriviaModel(
        number: (jsonRes['number'] as num).toInt(),
        text: jsonRes['text'],
      );

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'number': number,
        'text': text,
      };
}
