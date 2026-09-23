// lib/data/auth/bloc/verify/verify_state.dart
part of 'verify_bloc.dart';

@immutable
abstract class VerifyState {}

class VerifyInitial extends VerifyState {}
class VerifyLoading extends VerifyState {}
class VerifySuccess extends VerifyState {}

class VerifyFailure extends VerifyState {
  final String errorMessage;
  VerifyFailure(this.errorMessage);
}

class LogoutLoading extends VerifyState {}
class LogoutSuccess extends VerifyState {
  final String message;
  LogoutSuccess(this.message);
}

class LogoutFailure extends VerifyState {
  final String errorMessage;
  LogoutFailure(this.errorMessage);
}
