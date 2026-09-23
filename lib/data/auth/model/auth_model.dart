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
  final bool isAuthError;

  const VerifyModel(
      {required this.status, this.errorMessage, this.isAuthError = false});
}
