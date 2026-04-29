import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final String message;
  final String? code;

  const ErrorModel({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}
