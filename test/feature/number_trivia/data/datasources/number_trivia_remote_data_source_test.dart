import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tdd/core/error/exception.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd/feature/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockUri extends Mock implements Uri {}

void main() {
  late MockHttpClient mockHttpClient;
  late NumberTriviaRemoteDataSource dataSource;

  setUpAll(() {
    registerFallbackValue(MockUri());
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  tearDown(() {
    reset(mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
        'should preform a GET request on a URL with number being the endpoint and with application/json header',
        () {
      setUpMockHttpClientSuccess200();

      dataSource.getConcreteNumberTrivia(tNumber);
      verify(() => mockHttpClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {'Content-Type': 'application/json'}));
    });
    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200();

      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, tNumberTriviaModel);
    });
    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      setUpMockHttpClientFailure404();

      final callResult = dataSource.getConcreteNumberTrivia;
      expect(
          callResult(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));
    test(
        'should preform a GET request on a URL with number being the endpoint and with application/json header',
        () {
      setUpMockHttpClientSuccess200();

      dataSource.getRandomNumberTrivia();
      verify(() => mockHttpClient.get(Uri.parse('http://numbersapi.com/random'),
          headers: {'Content-Type': 'application/json'}));
    });
    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClientSuccess200();

      final result = await dataSource.getRandomNumberTrivia();
      expect(result, tNumberTriviaModel);
    });
    test(
        'should throw a ServerException when the response code is 404 or other',
        () async {
      setUpMockHttpClientFailure404();

      final callResult = dataSource.getRandomNumberTrivia;
      expect(callResult(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
