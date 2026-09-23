# Flutter BLoC Template — Design Spec

Tanggal: 2026-09-23. Sumber pola: `GGN/driver_tulus_app` (53 file, tanpa DI).
Status: draft — butuh review user sebelum implementation plan.

## 1. Tujuan

Template project Flutter reusable, state management BLoC (`flutter_bloc`).
Pola copy-paste dari driver app yang terbukti: repo static, bloc `part`/`part of`,
router slide custom, flow Splash → Verify → Login/Home.

## 2. Lokasi & package

- Folder baru: `/home/it-mobile/development/projects/flutter_bloc_template/`
- Package: `flutter_bloc_template`. Repo git terpisah (user `git init` sendiri).
- Scaffolding via `flutter create` (SDK terinstall di `~/development/flutter`).
- Tanpa commit oleh agent — user handle git (aturan GGN).

## 3. Struktur folder

```
lib/
├── main.dart                  # MyApp: MultiBlocProvider(Verify) + onGenerateRoute + id_ID
├── core/
│   ├── constants/constants.dart # apiUrl via kDebugMode, base image URL
│   ├── theme/app_themes.dart    # Material 3: ColorScheme.fromSeed, light only
│   └── utility/                 # date_formatter, price_formatter, text_formatter,
│                                #   share_preference_repository, notification_widget
├── data/
│   ├── auth/                    # login + verify bloc/model/repository
│   └── items/                   # contoh CRUD generik: bloc/model/repository
└── page/
    ├── splash_screen.dart
    ├── login.dart
    ├── home.dart                # list items
    ├── item_detail_page.dart
    └── widget/                  # custom_button, input_text, info_row, status_badge
test/
└── items_bloc_test.dart         # 1 bloc test via flutter_test saja
```

Meniru driver app (`data/` + `page/`), bukan `features/` ala sales-mobile.

## 4. API contoh: DummyJSON (open-source, gratis, tanpa key)

Base: `https://dummyjson.com` (debug dan release sama — placeholder diganti per proyek).

| Kebutuhan       | Method | Path            | Catatan                              |
|-----------------|--------|-----------------|--------------------------------------|
| Login           | POST   | `/auth/login`   | body `{username, password, expiresInMins}` → `{accessToken, ...}` |
| Verify token    | GET    | `/auth/me`      | header `Authorization: Bearer <accessToken>` |
| List items      | GET    | `/products?limit=20&skip=0` | `{products: [...], total, skip, limit}` |
| Detail item     | GET    | `/products/{id}` | 1 product object                    |

Kredensial demo: `username: emilys`, `password: emilyspass` (user valid DummyJSON).
Auth persistence tetap SharedPreferences key `authData` (JSON: token + user info),
sama seperti driver app — yang diganti hanya endpoint dan model.

## 5. Slice

### 5.1 Auth
- `Splash` → `VerifyBloc(VerifyRequested)` → sukses `/home`, gagal `/login`.
- `LoginBloc`: event `LoginRequested(username, password)` → `LoginRepo.login()`
  simpan `authData` → state sukses/gagal.
- `LoginRepo`, `VerifyRepo`: static class, `http` direct, `SocketException` →
  pesan "Tidak ada koneksi internet".

### 5.2 CRUD generik (`items`)
- `ItemsBloc` pola `part`/`part of`: `ItemsRequested` → list, `ItemDetailRequested(id)` → detail.
- `ItemsRepo` static: `getItems()`, `getItemDetail(id)`.
- Model `Product`: `fromJson`/`toJson` manual (`dart:convert`), field seperlunya
  (id, title, price, thumbnail, description).
- `HomePage`: list + pull refresh sederhana; tap → `/item_detail` via arguments Map.

### 5.3 Core shell
- Router: `_createRoute` slide 2 arah (masuk kiri, keluar kanan) — sederhanakan dari 4 arah driver app.
- Global `navigatorKey` + `scaffoldMessengerKey` di `main.dart`.
- Locale `id_ID`, `flutter_localizations`, `ThemeMode.light` terkunci.
- `ApiConfig`: `kDebugMode ? debugUrl : releaseUrl` (placeholder, tanpa ngrok hardcoded).

## 6. Dependencies

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  http: ^1.5.0
  shared_preferences: ^2.5.5
  intl: ^0.20.2
  flutter_localizations: {sdk: flutter}
dev_dependencies:
  flutter_test: {sdk: flutter}
  flutter_lints: ^5.0.0
```

Tanpa: get_it, equatable, bloc_test/mockito, camera/geolocator, screenutil,
lottie, svg, upgrader. Font sistem default (tanpa Figtree).

## 7. Testing

Satu file `test/items_bloc_test.dart`: Arrange-Act-Assert dengan `flutter_test`
saja (tanpa `bloc_test`). Cover: initial → loading → success list.
Mock http via subclass `http.BaseClient` di file test yang sama — tanpa mockito.

## 8. Yang disengaja di-skip (ponytail)

- DI (get_it): driver app membuktikan repo static cukup untuk skala ini.
- Mason brick: tambah kalau template dipakai >2x.
- Dark mode, flavor, l10n arb, CI/fastlane: tambah saat proyek nyata butuh.
- Equatable: state class kecil, `==` manual tidak dibutuhkan (bloc mengandalkan emit baru).
