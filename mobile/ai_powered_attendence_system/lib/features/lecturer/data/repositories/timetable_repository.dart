import 'dart:async';
import 'dart:io';

import '../../../../core/services/token_storage_service.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../models/course_models.dart';
import '../services/timetable_api_service.dart';

//! Timetable Repository

class TimetableRepository {
  static const String _notLoggedInMsg =
      'You are not logged in. Please sign in to continue.';

  //! Execute with Auto-Refresh

  static Future<CourseResult<T>> _execute<T>(
    Future<T> Function(String token) call,
  ) async {
    try {
      var token = await TokenStorageService.getAccessToken();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      try {
        final result = await call(token);
        return CourseSuccess(result);
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          final refreshRes = await AuthRepository.refresh();
          if (refreshRes is AuthSuccess) {
            final newToken = await TokenStorageService.getAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              final retried = await call(newToken);
              return CourseSuccess(retried);
            }
          }
        }
        return CourseFailure(e.message, statusCode: e.statusCode);
      }
    } on ApiException catch (e) {
      return CourseFailure(e.message, statusCode: e.statusCode);
    } on SocketException {
      return const CourseFailure(
        'No internet connection. Please check your network.',
      );
    } on TimeoutException {
      return const CourseFailure('Connection timed out. Please try again.');
    } catch (e) {
      return CourseFailure('Unexpected error: $e');
    }
  }

  //! Get Timetable

  static Future<CourseResult<List<CourseTimetableEntryResponseDto>>> getTimetable(
    String courseId,
  ) =>
      _execute((token) => TimetableApiService.getTimetable(
            courseId: courseId,
            accessToken: token,
          ));

  //! Create Timetable Entry

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      createTimetableEntry({
    required String courseId,
    required CreateCourseTimetableEntryRequestDto request,
  }) =>
      _execute((token) => TimetableApiService.createTimetableEntry(
            courseId: courseId,
            request: request,
            accessToken: token,
          ));

  //! Update Timetable Entry

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      updateTimetableEntry({
    required String courseId,
    required String entryId,
    required CreateCourseTimetableEntryRequestDto request,
  }) =>
      _execute((token) => TimetableApiService.updateTimetableEntry(
            courseId: courseId,
            entryId: entryId,
            request: request,
            accessToken: token,
          ));

  //! Delete Timetable Entry

  static Future<CourseResult<void>> deleteTimetableEntry({
    required String courseId,
    required String entryId,
  }) =>
      _execute((token) => TimetableApiService.deleteTimetableEntry(
            courseId: courseId,
            entryId: entryId,
            accessToken: token,
          ));
}
