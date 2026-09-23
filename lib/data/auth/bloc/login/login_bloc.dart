// lib/data/auth/bloc/login/login_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/data/auth/model/auth_model.dart';
import 'package:flutter_bloc_template/data/auth/repository/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepo repo;
  LoginBloc({LoginRepo? repo})
      : repo = repo ?? LoginRepo(),
        super(LoginInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final LoginModel data = await repo.login(e.username, e.password);
      if (data.status == 'failed') {
        emit(LoginFailure(data.errorMessage ?? 'Login gagal'));
        return;
      }
      await LoginRepo.saveAuthData(data);
      emit(LoginSuccess(displayName: data.user?.displayName ?? ''));
    } catch (_) {
      emit(LoginFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }
}
