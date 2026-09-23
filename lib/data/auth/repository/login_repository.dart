// lib/data/auth/repository/login_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_template/core/constants/api_config.dart';
import 'package:flutter_bloc_template/data/auth/model/auth_model.dart';

class LoginRepo {
  final http.Client client;
  LoginRepo({http.Client? client}) : client = client ?? http.Client();

  Future<LoginModel> login(String username, String password) async {
    try {
      final res = await client.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {'username': username, 'password': password, 'expiresInMins': 60}),
      );
      if (res.body.isEmpty) {
        return const LoginModel(
            status: 'failed',
            errorMessage: 'Respon dari server kosong. Silakan coba lagi.');
      }
      return LoginModel.fromJson(json.decode(res.body));
    } on SocketException {
      return const LoginModel(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const LoginModel(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  static Future<void> saveAuthData(LoginModel data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authData', json.encode(data.toJson()));
  }

  static Future<LoginModel?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('authData');
    if (raw == null) return null;
    try {
      return LoginModel.fromStorage(json.decode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authData');
  }

  static Future<bool> isAuthDataExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('authData');
  }
}
