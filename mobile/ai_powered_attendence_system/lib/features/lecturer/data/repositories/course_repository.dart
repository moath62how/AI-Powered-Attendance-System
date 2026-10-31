import 'dart:async';
import 'dart:io';

import '../../../../core/services/token_storage_service.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../models/course_models.dart';
import '../services/course_api_service.dart';
import 'timetable_repository.dart';

export '../models/course_result.dart';
export '../services/course_api_service.dart' show ApiException;
export 'timetable_repository.dart';

//! Course Repository

class CourseRepository {
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

  //! Create Course

  static Future<CourseResult<CourseResponseDto>> createCourse({
    required CreateCourseRequestDto request,
  }) =>
      _execute((token) => CourseApiService.createCourse(
            request: request,
            accessToken: token,
          ));

  //! Get Course By ID

  static Future<CourseResult<CourseResponseDto>> getCourseById(String id) =>
      _execute((token) => CourseApiService.getCourseById(
            id: id,
            accessToken: token,
          ));

  //! Update Course

  static Future<CourseResult<CourseResponseDto>> updateCourse({
    required String id,
    required UpdateCourseRequestDto request,
  }) =>
      _execute((token) => CourseApiService.updateCourse(
            id: id,
            request: request,
            accessToken: token,
          ));

  //! Delete Course

  static Future<CourseResult<void>> deleteCourse(String id) =>
      _execute((token) => CourseApiService.deleteCourse(
            courseId: id,
            accessToken: token,
          ));

  //! Get Management Details

  static Future<CourseResult<CourseManagementResponseDto>> getManagementDetails(
    String id,
  ) =>
      _execute((token) => CourseApiService.getManagementDetails(
            id: id,
            accessToken: token,
          ));

  //! Timetable Delegations

  static Future<CourseResult<List<CourseTimetableEntryResponseDto>>> getTimetable(
    String courseId,
  ) =>
      TimetableRepository.getTimetable(courseId);

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      createTimetableEntry({
    required String courseId,
    required CreateCourseTimetableEntryRequestDto request,
  }) =>
      TimetableRepository.createTimetableEntry(
        courseId: courseId,
        request: request,
      );

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      updateTimetableEntry({
    required String courseId,
    required String entryId,
    required CreateCourseTimetableEntryRequestDto request,
  }) =>
      TimetableRepository.updateTimetableEntry(
        courseId: courseId,
        entryId: entryId,
        request: request,
      );

  static Future<CourseResult<void>> deleteTimetableEntry({
    required String courseId,
    required String entryId,
  }) =>
      TimetableRepository.deleteTimetableEntry(
        courseId: courseId,
        entryId: entryId,
      );
}
