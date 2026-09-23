// lib/data/auth/repository/verify_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc_template/core/constants/api_config.dart';
import 'package:flutter_bloc_template/data/auth/model/auth_model.dart';
import 'package:flutter_bloc_template/data/auth/repository/login_repository.dart';

class VerifyRepo {
  final http.Client client;
  VerifyRepo({http.Client? client}) : client = client ?? http.Client();

  Future<VerifyModel> verify() async {
    final token = (await LoginRepo.getAuthData())?.token;
    if (token == null) {
      return const VerifyModel(
          status: 'failed', errorMessage: 'Token tidak ditemukan');
    }
    try {
      final res = await client.get(
        Uri.parse('$apiUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        return const VerifyModel(status: 'ok');
      }
      final msg = res.body.isNotEmpty
          ? json.decode(res.body)['message']?.toString()
          : null;
      return VerifyModel(
          status: 'failed', errorMessage: msg ?? 'Sesi berakhir. Login lagi.');
    } on SocketException {
      return const VerifyModel(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const VerifyModel(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }
}
