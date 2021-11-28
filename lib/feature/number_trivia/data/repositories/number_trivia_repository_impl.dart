import 'package:dartz/dartz.dart';
import 'package:tdd/core/error/exception.dart';
import 'package:tdd/core/error/failure.dart';
import 'package:tdd/core/platform/network_info.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:tdd/feature/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd/feature/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/feature/number_trivia/domain/repositories/number_trivia_repository.dart';

class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
      int number) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getConcreteNumberTrivia(number);
        await localDataSource.cacheNumberTrivia(result);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final result = await localDataSource.getLastNumberTrivia();
        return Right(result);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getRandomNumberTrivia();
        await localDataSource.cacheNumberTrivia(result);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final result = await localDataSource.getLastNumberTrivia();
        return Right(result);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
