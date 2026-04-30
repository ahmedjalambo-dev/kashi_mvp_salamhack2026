import 'error_model.dart';

sealed class Result<T> {
  const Result();
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final ErrorModel error;
  const Failure(this.error);
}
