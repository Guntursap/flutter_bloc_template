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
