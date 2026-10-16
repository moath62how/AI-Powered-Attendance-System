import 'dart:async';
import 'dart:io';

import '../../../../core/services/device_service.dart';
import '../../../../core/services/token_storage_service.dart';
import '../models/auth_models.dart';
import '../services/auth_api_service.dart';

export '../services/auth_api_service.dart' show ApiException;

/// Result type wrapping either a success value or an error message.
sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}

class AuthFailure<T> extends AuthResult<T> {
  final String message;
  final int? statusCode;
  const AuthFailure(this.message, {this.statusCode});
}

/// Business-logic layer for authentication.
///
/// Orchestrates [AuthApiService], [TokenStorageService], and [DeviceService].
/// All public methods return [AuthResult] — screens never see raw exceptions.
class AuthRepository {
  // ─── Login ──────────────────────────────────────────────────────────────

  static Future<AuthResult<AuthResponseDto>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      final request = LoginRequestDto(
        identifier: identifier.trim(),
        password: password,
        clientType: 'Mobile',
        deviceId: deviceId,
      );

      final response = await AuthApiService.login(request);

      await TokenStorageService.saveAuth(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      return AuthSuccess(response);
    } on ApiException catch (e) {
      return AuthFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const AuthFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const AuthFailure(
        'Connection timed out. Please try again.',
      );
    } catch (e) {
      return AuthFailure('Unexpected error: $e');
    }
  }

  // ─── Register ────────────────────────────────────────────────────────────

  static Future<AuthResult<UserDto>> register({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
    required String role, // 'Student' | 'Lecturer'
    String? studentId,
  }) async {
    try {
      final request = RegisterRequestDto(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phoneNumber: phoneNumber.trim(),
        email: email.trim(),
        password: password,
        role: role,
        studentId: studentId?.trim(),
      );

      final user = await AuthApiService.register(request);
      return AuthSuccess(user);
    } on ApiException catch (e) {
      return AuthFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const AuthFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const AuthFailure('Connection timed out. Please try again.');
    } catch (e) {
      return AuthFailure('Unexpected error: $e');
    }
  }

  // ─── Forgot Password ─────────────────────────────────────────────────────

  static Future<AuthResult<void>> forgotPassword(String email) async {
    try {
      await AuthApiService.forgotPassword(
        ForgotPasswordRequestDto(email: email.trim()),
      );
      return const AuthSuccess(null);
    } on ApiException catch (e) {
      return AuthFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const AuthFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const AuthFailure('Connection timed out. Please try again.');
    } catch (e) {
      return AuthFailure('Unexpected error: $e');
    }
  }

  // ─── Reset Password With OTP Code ────────────────────────────────────────

  static Future<AuthResult<void>> resetPasswordWithCode({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await AuthApiService.resetPasswordWithCode(
        ResetPasswordWithCodeRequestDto(
          email: email.trim(),
          code: code.trim(),
          newPassword: newPassword,
        ),
      );
      return const AuthSuccess(null);
    } on ApiException catch (e) {
      return AuthFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const AuthFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const AuthFailure('Connection timed out. Please try again.');
    } catch (e) {
      return AuthFailure('Unexpected error: $e');
    }
  }

  // ─── Refresh Token ────────────────────────────────────────────────────────

  static Future<AuthResult<AuthResponseDto>> refresh() async {
    try {
      final stored = await TokenStorageService.getRefreshToken();
      if (stored == null || stored.isEmpty) {
        return const AuthFailure('No refresh token found. Please log in again.');
      }

      final response = await AuthApiService.refresh(
        RefreshTokenRequestDto(refreshToken: stored),
      );

      await TokenStorageService.saveAuth(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        user: response.user,
      );

      return AuthSuccess(response);
    } on ApiException catch (e) {
      return AuthFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const AuthFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const AuthFailure('Connection timed out. Please try again.');
    } catch (e) {
      return AuthFailure('Unexpected error: $e');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    await TokenStorageService.clearAuth();
  }
}
