// test/auth_repository_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_template/data/auth/model/auth_model.dart';
import 'package:flutter_bloc_template/data/auth/repository/login_repository.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  MockClient okClient() => MockClient((req) async {
        if (req.url.path == '/auth/login') {
          return http.Response(
              json.encode({
                'id': 1,
                'username': 'emilys',
                'email': 'emily@test.com',
                'firstName': 'Emily',
                'lastName': 'Smith',
                'image': 'https://x/y.png',
                'accessToken': 'tok123',
              }),
              200);
        }
        return http.Response('not found', 404);
      });

  test('login sukses → status ok + token tersimpan', () async {
    final repo = LoginRepo(client: okClient());
    final res = await repo.login('emilys', 'emilyspass');
    expect(res.status, 'ok');
    expect(res.token, 'tok123');
    expect(res.user?.username, 'emilys');
    await LoginRepo.saveAuthData(res);
    expect(await LoginRepo.isAuthDataExists(), isTrue);
  });

  test('login 400 → status failed + pesan server', () async {
    final repo = LoginRepo(
        client: MockClient((_) async => http.Response(
            json.encode({'message': 'Invalid credentials'}), 400)));
    final res = await repo.login('x', 'y');
    expect(res.status, 'failed');
    expect(res.errorMessage, 'Invalid credentials');
  });

  test('offline → pesan Indonesia', () async {
    final repo = LoginRepo(
        client: MockClient((_) async => throw const SocketException('x')));
    final res = await repo.login('x', 'y');
    expect(res.status, 'failed');
    expect(res.errorMessage, contains('koneksi internet'));
  });

  test('round-trip authData via SharedPreferences', () async {
    const m = LoginModel(status: 'ok', token: 't', user: null);
    await LoginRepo.saveAuthData(m);
    final back = await LoginRepo.getAuthData();
    expect(back?.token, 't');
    await LoginRepo.clearAuthData();
    expect(await LoginRepo.getAuthData(), isNull);
  });
}
