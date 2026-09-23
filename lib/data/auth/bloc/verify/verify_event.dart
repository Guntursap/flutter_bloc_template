// lib/data/auth/bloc/verify/verify_event.dart
part of 'verify_bloc.dart';

@immutable
abstract class VerifyEvent {}

class VerifyRequested extends VerifyEvent {}
class LogoutRequested extends VerifyEvent {}
