import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdd/core/error/exception.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd/feature/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockSharedPreferences;
  late NumberTriviaLocalDataSourceImpl numberTriviaLocalDataSourceImpl;

  setUpAll(() {
    mockSharedPreferences = MockSharedPreferences();
    numberTriviaLocalDataSourceImpl =
        NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  tearDown(() {
    reset(mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));

    test(
        'should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      when(() => mockSharedPreferences.getString(cachedNumberTrivia))
          .thenReturn(fixture('trivia_cached.json'));

      final result =
          await numberTriviaLocalDataSourceImpl.getLastNumberTrivia();

      verify(() => mockSharedPreferences.getString(cachedNumberTrivia))
          .called(1);
      expect(result, tNumberTriviaModel);
    });

    test('should throw a CacheException when there is not a cached value',
        () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      final callResult = numberTriviaLocalDataSourceImpl.getLastNumberTrivia;

      expect(callResult(), throwsA(const TypeMatcher<CacheException>()));
      verify(() => mockSharedPreferences.getString(cachedNumberTrivia))
          .called(1);
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    final expectedJsonString = json.encode(tNumberTriviaModel.toJson());

    test('should call SharedPreferences to cache the data', () {
      numberTriviaLocalDataSourceImpl.cacheNumberTrivia(tNumberTriviaModel);

      verify(() => mockSharedPreferences.setString(
            cachedNumberTrivia,
            expectedJsonString,
          )).called(1);
    });
  });
}
