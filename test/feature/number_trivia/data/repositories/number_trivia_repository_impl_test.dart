import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd/core/error/exception.dart';
import 'package:tdd/core/error/failure.dart';
import 'package:tdd/core/network/network_info.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd/feature/number_trivia/data/models/number_trivia_model.dart';
import 'package:tdd/feature/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';

class MockNumberTriviaRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockNumberTriviaLocalDataSource extends Mock
    implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockNumberTriviaRemoteDataSource mockRemoteDataSource;
  late MockNumberTriviaLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late NumberTriviaRepositoryImpl repositoryImpl;

  setUpAll(() {
    mockRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repositoryImpl = NumberTriviaRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  tearDown(() {
    reset(mockRemoteDataSource);
    reset(mockLocalDataSource);
  });

  void runTestOnline(Function body) {
    group('device is online', () {
      setUpAll(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestOffline(Function body) {
    group('device is online', () {
      setUpAll(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    const tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .called(1);
          expect(result, const Right(tNumberTrivia));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .called(1);
          verify(() =>
                  mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .called(1);
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .thenThrow(ServerException());
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemoteDataSource.getConcreteNumberTrivia(tNumber))
              .called(1);
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure()));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);

          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, const Right(tNumberTrivia));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          final result = await repositoryImpl.getConcreteNumberTrivia(tNumber);

          verifyZeroInteractions(mockRemoteDataSource);

          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const tNumber = 123;
    const tNumberTriviaModel =
        NumberTriviaModel(number: tNumber, text: 'test trivia');
    const NumberTrivia tNumberTrivia = tNumberTriviaModel;

    runTestOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
          expect(result, const Right(tNumberTrivia));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
          verify(() =>
                  mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .called(1);
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());
          when(() => mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel))
              .thenAnswer((_) async => Future.value());

          final result = await repositoryImpl.getRandomNumberTrivia();

          verify(() => mockRemoteDataSource.getRandomNumberTrivia()).called(1);
          verifyZeroInteractions(mockLocalDataSource);
          expect(result, Left(ServerFailure()));
        },
      );
    });

    runTestOffline(() {
      test(
        'should return last locally cached data when the cached data is present',
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);

          final result = await repositoryImpl.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);

          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, const Right(tNumberTrivia));
        },
      );

      test(
        'should return CacheFailure when there is no cached data present',
        () async {
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          final result = await repositoryImpl.getRandomNumberTrivia();

          verifyZeroInteractions(mockRemoteDataSource);

          verify(() => mockLocalDataSource.getLastNumberTrivia()).called(1);
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });
}
