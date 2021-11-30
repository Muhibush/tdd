import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd/core/error/exception.dart';
import 'package:tdd/feature/number_trivia/data/models/number_trivia_model.dart';

const cachedNumberTrivia = 'CACHED_NUMBER_TRIVIA';

abstract class NumberTriviaLocalDataSource {
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

class NumberTriviaLocalDataSourceImpl extends NumberTriviaLocalDataSource {
  final SharedPreferences _sharedPreferences;

  NumberTriviaLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() async {
    final jsonString = _sharedPreferences.getString(cachedNumberTrivia);

    if (jsonString != null) {
      return NumberTriviaModel.fromJson(jsonDecode(jsonString));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    return _sharedPreferences.setString(
        cachedNumberTrivia, jsonEncode(triviaToCache.toJson()));
  }
}
