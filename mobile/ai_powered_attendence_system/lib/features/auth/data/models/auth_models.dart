// Dart mirror of the backend's auth DTOs.
// Mirrors: RegisterRequestDto, LoginRequestDto, AuthResponseDto, UserDto,
//          ForgotPasswordRequestDto, ResetPasswordWithCodeRequestDto,
//          RefreshTokenRequestDto.


// ─── User ──────────────────────────────────────────────────────────────────

class UserDto {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? studentId;
  final String role;
  final DateTime createdAt;

  const UserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.studentId,
    required this.role,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      studentId: json['studentId']?.toString(),
      role: (json['role'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// ─── Auth Response (Login / Refresh) ───────────────────────────────────────

class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAtUtc;
  final UserDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAtUtc,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
      expiresAtUtc: json['expiresAtUtc'] != null
          ? DateTime.tryParse(json['expiresAtUtc'].toString()) ?? DateTime.now()
          : DateTime.now(),
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// ─── Login Request ─────────────────────────────────────────────────────────

class LoginRequestDto {
  final String identifier;
  final String password;
  final String clientType;
  final String? deviceId;

  const LoginRequestDto({
    required this.identifier,
    required this.password,
    this.clientType = 'Mobile',
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'password': password,
      'clientType': clientType,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }
}

// ─── Register Request ──────────────────────────────────────────────────────

class RegisterRequestDto {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;
  final String role;
  final String? studentId;

  const RegisterRequestDto({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.role,
    this.studentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'password': password,
      'role': role,
      if (studentId != null) 'studentId': studentId,
    };
  }
}

// ─── Forgot Password Request ────────────────────────────────────────────────

class ForgotPasswordRequestDto {
  final String email;

  const ForgotPasswordRequestDto({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// ─── Reset Password With Code (OTP) ────────────────────────────────────────

class ResetPasswordWithCodeRequestDto {
  final String email;
  final String code;
  final String newPassword;

  const ResetPasswordWithCodeRequestDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      };
}

// ─── Refresh Token Request ──────────────────────────────────────────────────

class RefreshTokenRequestDto {
  final String refreshToken;

  const RefreshTokenRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
