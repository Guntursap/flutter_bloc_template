// lib/data/auth/bloc/verify/verify_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/data/auth/model/auth_model.dart';
import 'package:flutter_bloc_template/data/auth/repository/login_repository.dart';
import 'package:flutter_bloc_template/data/auth/repository/verify_repository.dart';

part 'verify_event.dart';
part 'verify_state.dart';

class VerifyBloc extends Bloc<VerifyEvent, VerifyState> {
  final VerifyRepo repo;
  VerifyBloc({VerifyRepo? repo})
      : repo = repo ?? VerifyRepo(),
        super(VerifyInitial()) {
    on<VerifyRequested>(_onVerify);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onVerify(VerifyRequested e, Emitter<VerifyState> emit) async {
    emit(VerifyLoading());
    try {
      final VerifyModel data = await repo.verify();
      if (data.status == 'failed') {
        await LoginRepo.clearAuthData();
        emit(VerifyFailure(data.errorMessage ?? 'Sesi berakhir'));
      } else {
        emit(VerifySuccess());
      }
    } catch (_) {
      emit(VerifyFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<VerifyState> emit) async {
    emit(LogoutLoading());
    if (await LoginRepo.isAuthDataExists()) {
      await LoginRepo.clearAuthData();
      emit(LogoutSuccess('Sampai jumpa lagi'));
    } else {
      emit(LogoutFailure('Logout gagal'));
    }
  }
}
