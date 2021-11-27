import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final List<dynamic> properties;

  const Failure({required this.properties});

  @override
  List<Object?> get props => [properties];
}
