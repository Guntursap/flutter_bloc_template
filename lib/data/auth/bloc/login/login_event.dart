// lib/data/auth/bloc/login/login_event.dart
part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String username;
  final String password;
  LoginRequested({required this.username, required this.password});
}
