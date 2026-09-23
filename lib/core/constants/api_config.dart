// lib/core/constants/api_config.dart
import 'package:flutter/foundation.dart';

// ponytail: satu base URL untuk debug+release; ganti per proyek.
// Kalau butuh beda URL per environment, pakai --dart-define API_URL=...
const String apiUrl = kDebugMode
    ? 'https://dummyjson.com'
    : 'https://dummyjson.com';
