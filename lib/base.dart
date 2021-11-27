abstract class UseCase<Type, Params>{
  Future<String> call(Params params);
}

class NoParams{

}