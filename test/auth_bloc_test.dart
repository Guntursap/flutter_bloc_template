// test/auth_bloc_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_template/data/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc_template/data/auth/bloc/verify/verify_bloc.dart';
import 'package:flutter_bloc_template/data/auth/repository/login_repository.dart';
import 'package:flutter_bloc_template/data/auth/repository/verify_repository.dart';

MockClient authClient() => MockClient((req) async {
      if (req.url.path == '/auth/login') {
        return http.Response(
            json.encode({
              'id': 1, 'username': 'emilys', 'email': 'e@t.co',
              'firstName': 'Emily', 'lastName': 'S', 'image': '',
              'accessToken': 'tok',
            }),
            200);
      }
      if (req.url.path == '/auth/me') {
        return http.Response(json.encode({'id': 1, 'username': 'emilys'}), 200);
      }
      return http.Response(json.encode({'message': 'nope'}), 401);
    });

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('LoginBloc: Loading → Success', () async {
    final bloc = LoginBloc(repo: LoginRepo(client: authClient()));
    bloc.add(LoginRequested(username: 'emilys', password: 'emilyspass'));
    await expectLater(
        bloc.stream, emitsInOrder([isA<LoginLoading>(), isA<LoginSuccess>()]));
    await bloc.close();
  });

  test('LoginBloc: kredensial salah → Failure bawa pesan server', () async {
    final bloc = LoginBloc(
        repo: LoginRepo(
            client: MockClient((_) async => http.Response(
                json.encode({'message': 'Invalid credentials'}), 400))));
    bloc.add(LoginRequested(username: 'x', password: 'y'));
    await expectLater(bloc.stream,
        emitsInOrder([isA<LoginLoading>(), isA<LoginFailure>()]));
    await bloc.close();
  });

  test('VerifyBloc: tanpa token → Failure', () async {
    final bloc = VerifyBloc(repo: VerifyRepo(client: authClient()));
    bloc.add(VerifyRequested());
    await expectLater(bloc.stream,
        emitsInOrder([isA<VerifyLoading>(), isA<VerifyFailure>()]));
    await bloc.close();
  });

  test('VerifyBloc: token valid → Success; logout hapus authData', () async {
    await LoginRepo.saveAuthData(
        await LoginRepo(client: authClient()).login('e', 'p'));
    final bloc = VerifyBloc(repo: VerifyRepo(client: authClient()));
    bloc.add(VerifyRequested());
    await expectLater(bloc.stream,
        emitsInOrder([isA<VerifyLoading>(), isA<VerifySuccess>()]));
    bloc.add(LogoutRequested());
    await expectLater(bloc.stream,
        emitsInOrder([isA<LogoutLoading>(), isA<LogoutSuccess>()]));
    expect(await LoginRepo.getAuthData(), isNull);
    await bloc.close();
  });
}
