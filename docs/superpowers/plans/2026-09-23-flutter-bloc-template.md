# Flutter BLoC Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold `flutter_bloc_template/` — pola driver app (auth + 1 CRUD generik + Material 3) dengan API DummyJSON.

**Architecture:** Tiru `GGN/driver_tulus_app`: repo instance (bukan static — supaya bisa inject `http.Client` palsu di test), bloc `part`/`part of`, router `_createRoute` slide, SharedPreferences key `authData`. Satu-satunya deviasi dari driver app: repo jadi instance class (static = untestable).

**Tech Stack:** Flutter 3.44.4 (stable, tanpa FVM) · Dart 3.12 · `flutter_bloc ^9.1.1`, `http ^1.5.0`, `shared_preferences ^2.5.5`, `intl ^0.20.2` · test hanya `flutter_test`.

**Spec:** `/home/it-mobile/development/projects/flutter_bloc_template/docs/superpowers/specs/2026-09-23-flutter-bloc-template-design.md`

## Global Constraints

- Flutter SDK di `~/development/flutter/bin` — semua command `flutter` pakai PATH itu.
- Folder kerja: `/home/it-mobile/development/projects/flutter_bloc_template/`. JANGAN sentuh folder GGN.
- `ThemeMode.light` terkunci, locale `id_ID`, tanpa font custom (font sistem).
- JANGAN tambah dep di luar spec (tanpa get_it/equatable/bloc_test/mockito).
- Kredensial demo DummyJSON: `emilys` / `emilyspass` — tulis di README, jangan hardcode di source.
- JANGAN `git init`/`git add`/`git commit` — user handle git.

## Review Focus

- Login username/password salah → pesan DummyJSON `Invalid credentials` tampil di UI, bukan crash. (test di Task 4)
- Token kadaluarsa → Verify gagal → authData dihapus → redirect `/login`. (test di Task 4)
- Produk kosong / `products` null → list tampil empty state, bukan crash. (test di Task 6)
- Offline (`SocketException`) → pesan Indonesia "Tidak ada koneksi internet". (test di Task 3)
- Detail id tidak ada (404 DummyJSON) → Failure state dengan pesan server. (test di Task 6)

---

### Task 1: Scaffold proyek + pubspec

**Files:**
- Create via command: `flutter create` output (`lib/main.dart` default, `pubspec.yaml`, `analysis_options.yaml`, dst.)
- Modify: `pubspec.yaml` (deps), delete: `test/widget_test.dart` (counter bawaan)
- Test: `flutter analyze` (lolos tanpa error)

**Interfaces:**
- Consumes: —
- Produces: package name `flutter_bloc_template` untuk semua import lintas task (`package:flutter_bloc_template/...`).

- [ ] **Step 1: Scaffold**

Run:
```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd /home/it-mobile/development/projects
flutter create --project-name flutter_bloc_template --org com.example flutter_bloc_template
```

- [ ] **Step 2: Set pubspec deps**

Ganti blok `dependencies:` / `dev_dependencies:` di `flutter_bloc_template/pubspec.yaml` jadi:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_bloc: ^9.1.1
  bloc: ^9.0.0
  http: ^1.5.0
  shared_preferences: ^2.5.5
  intl: ^0.20.2
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```
Hapus `test/widget_test.dart` bawaan (`rm test/widget_test.dart`).

- [ ] **Step 3: Install + analyze**

Run:
```bash
cd /home/it-mobile/development/projects/flutter_bloc_template
flutter pub get
flutter analyze
```
Expected: `No issues found!`

---

### Task 2: Core (constants, theme, utility) + app shell

**Files:**
- Create: `lib/core/constants/api_config.dart`
- Create: `lib/core/theme/app_themes.dart`
- Create: `lib/core/utility/formatters.dart`
- Create: `lib/core/utility/notification_widget.dart`
- Create: `lib/main.dart` (overwrite scaffold)
- Test: `test/app_shell_test.dart` (MyApp pump → SplashScreen tampil)

**Interfaces:**
- Consumes: package name dari Task 1.
- Produces: `ApiConfig.apiUrl` (dipakai repo Task 3/6), `AppTheme.light()` (dipakai main), `scaffoldMessengerKey` + `navigatorKey` global (dipakai page Task 5/8), route names `/login`, `/home`, `/item_detail`.

- [ ] **Step 1: api_config**

```dart
// lib/core/constants/api_config.dart
import 'package:flutter/foundation.dart';

// ponytail: satu base URL untuk debug+release; ganti per proyek.
// Kalau butuh beda URL per environment, pakai --dart-define API_URL=...
const String apiUrl = kDebugMode
    ? 'https://dummyjson.com'
    : 'https://dummyjson.com';
```

- [ ] **Step 2: theme M3 default**

```dart
// lib/core/theme/app_themes.dart
import 'package:flutter/material.dart';

@immutable
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const seed = Color(0xFF1A56DB);
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: formatters**

```dart
// lib/core/utility/formatters.dart
import 'package:intl/intl.dart';

String formatPrice(num value) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(value);

String formatDate(DateTime date) =>
    DateFormat('dd MMM yyyy', 'id_ID').format(date);

String trimText(String text, [int max = 60]) =>
    text.length <= max ? text : '${text.substring(0, max)}…';
```

- [ ] **Step 4: notification widget**

```dart
// lib/core/utility/notification_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/main.dart'
    show scaffoldMessengerKey;

void showAppMessage(String message, {bool isError = false}) {
  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
}
```

- [ ] **Step 5: main.dart shell**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc_template/core/theme/app_themes.dart';
import 'package:flutter_bloc_template/data/auth/bloc/verify/verify_bloc.dart';
import 'package:flutter_bloc_template/page/home.dart';
import 'package:flutter_bloc_template/page/item_detail_page.dart';
import 'package:flutter_bloc_template/page/login.dart';
import 'package:flutter_bloc_template/page/splash_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VerifyBloc>(
      create: (_) => VerifyBloc()..add(VerifyRequested()),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        onGenerateRoute: createRoute,
        locale: const Locale('id', 'ID'),
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: BlocListener<VerifyBloc, VerifyState>(
          listener: (context, state) {
            if (state is VerifySuccess) {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            } else if (state is VerifyFailure) {
              navigatorKey.currentState?.pushReplacementNamed('/login');
            }
          },
          child: const SplashScreen(),
        ),
      ),
    );
  }
}

Route<dynamic> createRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case '/home':
      page = const HomePage();
    case '/item_detail':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      page = ItemDetailPage(itemId: (args['id'] as num?)?.toInt() ?? 0);
    case '/login':
      page = const LoginPage();
    default:
      page = const SplashScreen();
  }
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, animation, _, child) {
      final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}
```
File `page/*.dart` dan `data/auth/bloc/verify/*` belum ada — import akan merah sampai Task 4/5/8. Itu ekspektasi (compile per task, bukan per step).

- [ ] **Step 6: shell test (tulis dulu, merah dulu)**

```dart
// test/app_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc_template/main.dart';

void main() {
  testWidgets('MyApp tampilkan SplashScreen saat start', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('Template'), findsOneWidget);
  });
}
```
(`SplashScreen` Task 5 harus memuat teks `Template` — kontrak antar task.)

- [ ] **Step 7: Run test, expect FAIL (file page/bloc belum ada)**

Run: `flutter test test/app_shell_test.dart`. Expected: FAIL compile error. Lanjut — akan hijau setelah Task 5 + Task 8.

---

### Task 3: Auth model + repository (+ test)

**Files:**
- Create: `lib/data/auth/model/auth_model.dart`
- Create: `lib/data/auth/repository/login_repository.dart`
- Create: `lib/data/auth/repository/verify_repository.dart`
- Test: `test/auth_repository_test.dart`

**Interfaces:**
- Consumes: `ApiConfig.apiUrl` (Task 2).
- Produces: `LoginModel{status, token, user, errorMessage}`, `AuthUser{id, username, email, firstName, lastName, image}`, `VerifyModel{status, errorMessage}`, `LoginRepo.login/saveAuthData/getAuthData/clearAuthData/isAuthDataExists`, `VerifyRepo.verify` — dipakai bloc Task 4.

DummyJSON kontrak (dipegang teguh, jangan ngarang field):
- `POST /auth/login {username, password, expiresInMins: 60}` → 200 `{id, username, email, firstName, lastName, image, accessToken, refreshToken}`; kredensial salah → 400 `{message: "Invalid credentials"}`.
- `GET /auth/me` + `Authorization: Bearer <token>` → 200 user object; token jelek → 401 `{message: "Invalid/Expired Token!"}`.

- [ ] **Step 1: Test repo (merah dulu)**

```dart
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
```
(`MockClient` dari `package:http/testing.dart` — bagian dari `http`, bukan dep baru.)

- [ ] **Step 2: Run, expect FAIL** (`Target of URI doesn't exist`). Run: `flutter test test/auth_repository_test.dart`.

- [ ] **Step 3: Model**

```dart
// lib/data/auth/model/auth_model.dart
class AuthUser {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String image;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.image,
  });

  String get displayName => '$firstName $lastName'.trim();

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['firstName']?.toString() ?? '',
        lastName: json['lastName']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'image': image,
      };
}

class LoginModel {
  final String status; // 'ok' | 'failed'
  final String? token;
  final AuthUser? user;
  final String? errorMessage;

  const LoginModel(
      {required this.status, this.token, this.user, this.errorMessage});

  /// Sukses DummyJSON: ada `accessToken`. Gagal: `{message}`.
  factory LoginModel.fromJson(Map<String, dynamic> json) {
    if (json['accessToken'] != null) {
      return LoginModel(
        status: 'ok',
        token: json['accessToken'].toString(),
        user: AuthUser.fromJson(json),
      );
    }
    return LoginModel(
      status: 'failed',
      errorMessage: json['message']?.toString() ?? 'Login gagal',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'token': token,
        'user': user?.toJson(),
        'message': errorMessage,
      };

  static LoginModel? fromStorage(Map<String, dynamic> json) {
    if (json['token'] == null) return null;
    final u = json['user'];
    return LoginModel(
      status: json['status']?.toString() ?? 'ok',
      token: json['token'].toString(),
      user: u is Map<String, dynamic> ? AuthUser.fromJson(u) : null,
    );
  }
}

class VerifyModel {
  final String status;
  final String? errorMessage;

  const VerifyModel({required this.status, this.errorMessage});
}
```

- [ ] **Step 4: Repositories**

```dart
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
```

```dart
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
```

- [ ] **Step 5: Run test, expect PASS.** Run: `flutter test test/auth_repository_test.dart`.

---

### Task 4: Auth blocs (+ test)

**Files:**
- Create: `lib/data/auth/bloc/login/login_bloc.dart`, `login_event.dart`, `login_state.dart`
- Create: `lib/data/auth/bloc/verify/verify_bloc.dart`, `verify_event.dart`, `verify_state.dart`
- Test: `test/auth_bloc_test.dart`

**Interfaces:**
- Consumes: `LoginRepo`, `VerifyRepo`, `LoginModel` (Task 3).
- Produces: `LoginBloc`, `LoginRequested(username, password)`, `LoginLoading/Success(displayName)/Failure(errorMessage)`, `VerifyBloc`, `VerifyRequested/LogoutRequested`, `VerifyInitial/Loading/Success/Failure(errorMessage)`, `LogoutLoading/Success(message)/Failure(errorMessage)` — dipakai main + page (Task 2/5).

- [ ] **Step 1: Test bloc (merah dulu)**

```dart
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
```

- [ ] **Step 2: Run, expect FAIL** (file bloc belum ada).

- [ ] **Step 3: Login bloc**

```dart
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
```
```dart
// lib/data/auth/bloc/login/login_event.dart
part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String username;
  final String password;
  LoginRequested({required this.username, required this.password});
}
```
```dart
// lib/data/auth/bloc/login/login_state.dart
part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String displayName;
  LoginSuccess({required this.displayName});
}

class LoginFailure extends LoginState {
  final String errorMessage;
  LoginFailure(this.errorMessage);
}
```

- [ ] **Step 4: Verify bloc**

```dart
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
```
```dart
// lib/data/auth/bloc/verify/verify_event.dart
part of 'verify_bloc.dart';

@immutable
abstract class VerifyEvent {}

class VerifyRequested extends VerifyEvent {}
class LogoutRequested extends VerifyEvent {}
```
```dart
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
```

- [ ] **Step 5: Run test, expect PASS.** Run: `flutter test test/auth_bloc_test.dart`.

---

### Task 5: Auth pages (splash + login)

**Files:**
- Create: `lib/page/splash_screen.dart` (HARUS memuat teks `Template` — kontrak test Task 2)
- Create: `lib/page/login.dart`
- Create: `lib/page/widget/custom_button.dart`, `lib/page/widget/input_text.dart`
- Test: `test/login_page_test.dart` (render fields + tombol; tap tanpa isi → tetap di page)

**Interfaces:**
- Consumes: `LoginBloc` + states (Task 4), `showAppMessage` (Task 2), route `/home` (Task 2).
- Produces: `SplashScreen`, `LoginPage` — dipakai `main.dart` (Task 2, sudah import).

- [ ] **Step 1: Test page (merah dulu)**

```dart
// test/login_page_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_template/data/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc_template/page/login.dart';

void main() {
  testWidgets('LoginPage render username+password+tombol', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(create: (_) => LoginBloc(), child: const LoginPage()),
      ),
    );
    expect(find.byKey(const Key('username')), findsOneWidget);
    expect(find.byKey(const Key('password')), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Widgets + pages**

```dart
// lib/page/widget/input_text.dart
import 'package:flutter/material.dart';

class InputText extends StatelessWidget {
  final Key? fieldKey;
  final String label;
  final TextEditingController controller;
  final bool obscure;
  const InputText(
      {super.key, this.fieldKey, required this.label,
       required this.controller, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: fieldKey,
      controller: controller,
      obscureText: obscure,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}
```
```dart
// lib/page/widget/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, child: Text(text)),
    );
  }
}
```
```dart
// lib/page/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlutterLogo(size: 72),
            SizedBox(height: 16),
            Text('Template'),
            SizedBox(height: 8),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```
```dart
// lib/page/login.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/notification_widget.dart';
import 'package:flutter_bloc_template/data/auth/bloc/login/login_bloc.dart';
import 'package:flutter_bloc_template/page/widget/custom_button.dart';
import 'package:flutter_bloc_template/page/widget/input_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _user = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Masuk')),
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginFailure) {
              showAppMessage(state.errorMessage, isError: true);
            } else if (state is LoginSuccess) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
          builder: (context, state) {
            final loading = state is LoginLoading;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  InputText(
                      fieldKey: const Key('username'),
                      label: 'Username',
                      controller: _user),
                  const SizedBox(height: 12),
                  InputText(
                      fieldKey: const Key('password'),
                      label: 'Password',
                      controller: _pass,
                      obscure: true),
                  const SizedBox(height: 20),
                  if (loading)
                    const CircularProgressIndicator()
                  else
                    CustomButton(
                      text: 'Masuk',
                      onPressed: () => context.read<LoginBloc>().add(
                          LoginRequested(
                              username: _user.text.trim(),
                              password: _pass.text)),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run page test + shell test, expect PASS.**

Run:
```bash
flutter test test/login_page_test.dart test/app_shell_test.dart
```
`app_shell_test` hijau sekarang (Task 4 selesaikan `VerifyBloc`; HomePage masih stub? `main.dart` import `page/home.dart` — BELUM ADA. Tambahkan stub sementara? TIDAK — kerjakan Task 6–8 dulu, shell test butuh HomePage. Catat: `app_shell_test` full-hijau di Task 8.)

---

### Task 6: Items data (model + repo + test)

**Files:**
- Create: `lib/data/items/model/product.dart`
- Create: `lib/data/items/repository/items_repository.dart`
- Test: `test/items_repository_test.dart`

**Interfaces:**
- Consumes: `ApiConfig.apiUrl` (Task 2).
- Produces: `Product{id, title, description, price, thumbnail}`, `ProductListResponse{status, products, total, errorMessage}`, `ProductDetailResponse{status, product, errorMessage}`, `ItemsRepo.getItems({limit, skip})/getItemDetail(id)` — dipakai bloc Task 7.

DummyJSON: `GET /products?limit=&skip=` → `{products:[{id,title,description,price,thumbnail,...}], total, skip, limit}`; `GET /products/{id}` → product; id jelek → 404 `{message}`.

- [ ] **Step 1: Test (merah dulu)**

```dart
// test/items_repository_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

Map<String, dynamic> prod(int id) => {
      'id': id, 'title': 'Item $id', 'description': 'Desc',
      'price': 100, 'thumbnail': 'https://x/y.png',
    };

void main() {
  test('getItems → list + total', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => http.Response(
            json.encode({'products': [prod(1), prod(2)], 'total': 194}),
            200)));
    final res = await repo.getItems(limit: 2);
    expect(res.status, 'ok');
    expect(res.products.length, 2);
    expect(res.total, 194);
  });

  test('getItems products null → failed, tidak crash', () async {
    final repo = ItemsRepo(
        client: MockClient(
            (_) async => http.Response(json.encode({'products': null}), 200)));
    final res = await repo.getItems();
    expect(res.status, 'failed');
    expect(res.products, isEmpty);
  });

  test('getItemDetail 404 → failed bawa pesan server', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => http.Response(
            json.encode({'message': 'Product with id 0 not found'}), 404)));
    final res = await repo.getItemDetail(0);
    expect(res.status, 'failed');
    expect(res.errorMessage, contains('not found'));
  });

  test('offline → pesan Indonesia', () async {
    final repo = ItemsRepo(
        client: MockClient((_) async => throw const SocketException('x')));
    final res = await repo.getItems();
    expect(res.errorMessage, contains('koneksi internet'));
  });
}
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Model + repo**

```dart
// lib/data/items/model/product.dart
class Product {
  final int id;
  final String title;
  final String description;
  final num price;
  final String thumbnail;

  const Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.thumbnail});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: json['price'] as num? ?? 0,
        thumbnail: json['thumbnail']?.toString() ?? '',
      );
}

class ProductListResponse {
  final String status;
  final List<Product> products;
  final int total;
  final String? errorMessage;

  const ProductListResponse(
      {required this.status,
      this.products = const [],
      this.total = 0,
      this.errorMessage});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['products'];
    if (list is! List) {
      return ProductListResponse(
          status: 'failed',
          errorMessage: json['message']?.toString() ?? 'Data kosong');
    }
    return ProductListResponse(
      status: 'ok',
      products: list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProductDetailResponse {
  final String status;
  final Product? product;
  final String? errorMessage;

  const ProductDetailResponse(
      {required this.status, this.product, this.errorMessage});

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      return ProductDetailResponse(
          status: 'failed',
          errorMessage: json['message']?.toString() ?? 'Data tidak ditemukan');
    }
    return ProductDetailResponse(
        status: 'ok', product: Product.fromJson(json));
  }
}
```
```dart
// lib/data/items/repository/items_repository.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc_template/core/constants/api_config.dart';
import 'package:flutter_bloc_template/data/items/model/product.dart';

class ItemsRepo {
  final http.Client client;
  ItemsRepo({http.Client? client}) : client = client ?? http.Client();

  Future<ProductListResponse> getItems({int limit = 20, int skip = 0}) async {
    try {
      final res = await client
          .get(Uri.parse('$apiUrl/products?limit=$limit&skip=$skip'));
      if (res.body.isEmpty) {
        return const ProductListResponse(
            status: 'failed', errorMessage: 'Respon server kosong');
      }
      return ProductListResponse.fromJson(json.decode(res.body));
    } on SocketException {
      return const ProductListResponse(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const ProductListResponse(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  Future<ProductDetailResponse> getItemDetail(int id) async {
    try {
      final res = await client.get(Uri.parse('$apiUrl/products/$id'));
      if (res.body.isEmpty) {
        return const ProductDetailResponse(
            status: 'failed', errorMessage: 'Respon server kosong');
      }
      return ProductDetailResponse.fromJson(json.decode(res.body));
    } on SocketException {
      return const ProductDetailResponse(
          status: 'failed',
          errorMessage: 'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (_) {
      return const ProductDetailResponse(
          status: 'failed',
          errorMessage: 'Terjadi kesalahan. Silakan coba lagi.');
    }
  }
}
```

- [ ] **Step 4: Run test, expect PASS.** Run: `flutter test test/items_repository_test.dart`.

---

### Task 7: Items bloc (+ test)

**Files:**
- Create: `lib/data/items/bloc/items_bloc.dart`, `items_event.dart`, `items_state.dart`
- Test: `test/items_bloc_test.dart`

**Interfaces:**
- Consumes: `ItemsRepo`, response models (Task 6).
- Produces: `ItemsBloc`, `ItemsRequested/ItemDetailRequested(id)`, `ItemsInitial/ItemsLoading/ItemsSuccess(products, total)/ItemsFailure(errorMessage)`, `ItemDetailLoading/ItemDetailSuccess(product)/ItemDetailFailure(errorMessage)` — dipakai page Task 8.

- [ ] **Step 1: Test (merah dulu)**

```dart
// test/items_bloc_test.dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

void main() {
  MockClient client() => MockClient((req) async {
        if (req.url.path == '/products') {
          return http.Response(
              json.encode({
                'products': [
                  {'id': 1, 'title': 'A', 'price': 10}
                ],
                'total': 1
              }),
              200);
        }
        return http.Response(
            json.encode({'id': 1, 'title': 'A', 'price': 10}), 200);
      });

  test('ItemsRequested: Loading → Success', () async {
    final bloc = ItemsBloc(repo: ItemsRepo(client: client()));
    bloc.add(ItemsRequested());
    await expectLater(bloc.stream,
        emitsInOrder([isA<ItemsLoading>(), isA<ItemsSuccess>()]));
    await bloc.close();
  });

  test('ItemDetailRequested: Loading → DetailSuccess', () async {
    final bloc = ItemsBloc(repo: ItemsRepo(client: client()));
    bloc.add(ItemDetailRequested(1));
    await expectLater(bloc.stream,
        emitsInOrder([isA<ItemDetailLoading>(), isA<ItemDetailSuccess>()]));
    await bloc.close();
  });
}
```

- [ ] **Step 2: Run, expect FAIL.**

- [ ] **Step 3: Bloc**

```dart
// lib/data/items/bloc/items_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/data/items/model/product.dart';
import 'package:flutter_bloc_template/data/items/repository/items_repository.dart';

part 'items_event.dart';
part 'items_state.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemsRepo repo;
  ItemsBloc({ItemsRepo? repo})
      : repo = repo ?? ItemsRepo(),
        super(ItemsInitial()) {
    on<ItemsRequested>(_onList);
    on<ItemDetailRequested>(_onDetail);
  }

  Future<void> _onList(ItemsRequested e, Emitter<ItemsState> emit) async {
    emit(ItemsLoading());
    try {
      final res = await repo.getItems();
      if (res.status == 'failed') {
        emit(ItemsFailure(res.errorMessage ?? 'Gagal memuat data'));
      } else {
        emit(ItemsSuccess(products: res.products, total: res.total));
      }
    } catch (_) {
      emit(ItemsFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onDetail(
      ItemDetailRequested e, Emitter<ItemsState> emit) async {
    emit(ItemDetailLoading());
    try {
      final res = await repo.getItemDetail(e.id);
      if (res.status == 'failed' || res.product == null) {
        emit(ItemDetailFailure(res.errorMessage ?? 'Data tidak ditemukan'));
      } else {
        emit(ItemDetailSuccess(product: res.product!));
      }
    } catch (_) {
      emit(ItemDetailFailure('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }
}
```
```dart
// lib/data/items/bloc/items_event.dart
part of 'items_bloc.dart';

@immutable
abstract class ItemsEvent {}

class ItemsRequested extends ItemsEvent {}

class ItemDetailRequested extends ItemsEvent {
  final int id;
  ItemDetailRequested(this.id);
}
```
```dart
// lib/data/items/bloc/items_state.dart
part of 'items_bloc.dart';

@immutable
abstract class ItemsState {}

class ItemsInitial extends ItemsState {}
class ItemsLoading extends ItemsState {}

class ItemsSuccess extends ItemsState {
  final List<Product> products;
  final int total;
  ItemsSuccess({required this.products, required this.total});
}

class ItemsFailure extends ItemsState {
  final String errorMessage;
  ItemsFailure(this.errorMessage);
}

class ItemDetailLoading extends ItemsState {}
class ItemDetailFailure extends ItemsState {
  final String errorMessage;
  ItemDetailFailure(this.errorMessage);
}

class ItemDetailSuccess extends ItemsState {
  final Product product;
  ItemDetailSuccess({required this.product});
}
```

- [ ] **Step 4: Run test, expect PASS.** Run: `flutter test test/items_bloc_test.dart`.

---

### Task 8: Home + detail pages, README, verifikasi penuh

**Files:**
- Create: `lib/page/home.dart`
- Create: `lib/page/item_detail_page.dart`
- Create: `README.md`
- Test: full suite `flutter test` + `flutter analyze`

**Interfaces:**
- Consumes: `ItemsBloc` (Task 7), `VerifyBloc/LogoutRequested` (Task 4), `formatPrice` (Task 2), routes `/item_detail`, `/login` (Task 2).

- [ ] **Step 1: HomePage**

```dart
// lib/page/home.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/formatters.dart';
import 'package:flutter_bloc_template/core/utility/notification_widget.dart';
import 'package:flutter_bloc_template/data/auth/bloc/verify/verify_bloc.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ItemsBloc()..add(ItemsRequested())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Items'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<VerifyBloc>().add(LogoutRequested()),
            ),
          ],
        ),
        body: BlocConsumer<VerifyBloc, VerifyState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.pushReplacementNamed(context, '/login');
            } else if (state is LogoutFailure) {
              showAppMessage(state.errorMessage, isError: true);
            }
          },
          listenWhen: (p, c) => c is LogoutSuccess || c is LogoutFailure,
          builder: (context, _) => BlocBuilder<ItemsBloc, ItemsState>(
            builder: (context, state) => switch (state) {
              ItemsLoading() =>
                const Center(child: CircularProgressIndicator()),
              ItemsFailure(:final errorMessage) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<ItemsBloc>()
                            .add(ItemsRequested()),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ItemsSuccess(:final products) when products.isEmpty =>
                const Center(child: Text('Belum ada data')),
              ItemsSuccess(:final products, :final total) =>
                RefreshIndicator(
                  onRefresh: () async => context
                      .read<ItemsBloc>()
                      .add(ItemsRequested()),
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return ListTile(
                        title: Text(p.title),
                        subtitle: Text(formatPrice(p.price)),
                        trailing: Text('#$total'),
                        onTap: () => Navigator.pushNamed(
                          context, '/item_detail',
                          arguments: {'id': p.id},
                        ),
                      );
                    },
                  ),
                ),
              _ => const SizedBox(),
            },
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: ItemDetailPage**

```dart
// lib/page/item_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/core/utility/formatters.dart';
import 'package:flutter_bloc_template/data/items/bloc/items_bloc.dart';

class ItemDetailPage extends StatelessWidget {
  final int itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemsBloc()..add(ItemDetailRequested(itemId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Detail')),
        body: BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) => switch (state) {
            ItemDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            ItemDetailFailure(:final errorMessage) =>
              Center(child: Text(errorMessage)),
            ItemDetailSuccess(:final product) => ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(product.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(formatPrice(product.price),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 12),
                  Text(product.description),
                ],
              ),
            _ => const SizedBox(),
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: README**

```markdown
# flutter_bloc_template

Template Flutter + `flutter_bloc`, pola dari `driver_tulus_app` GGN.
API contoh: [DummyJSON](https://dummyjson.com) (gratis, tanpa key).

## Run

```bash
flutter pub get
flutter run
```

Login demo: `emilys` / `emilyspass`.

## Struktur

`lib/core` (constants/theme/utility) · `lib/data/{auth,items}` (bloc/model/repository)
· `lib/page` (splash/login/home/detail + widget).

## Tambah fitur baru

Copy folder `lib/data/items` → rename. Daftarkan route di `createRoute()` (`lib/main.dart`).
```

- [ ] **Step 4: Verifikasi penuh**

Run:
```bash
flutter analyze
flutter test
```
Expected: `No issues found!` + `All tests passed!` (6 file test: app_shell, login_page, auth_repository, auth_bloc, items_repository, items_bloc).

- [ ] **Step 5: Lapor selesai (TANPA commit — user handle git).**
