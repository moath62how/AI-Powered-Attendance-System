import 'dart:async';
import 'dart:io';

import '../../../../core/services/token_storage_service.dart';
import '../models/course_models.dart';
import '../services/course_api_service.dart';
import 'timetable_repository.dart';

export '../models/course_result.dart';
export '../services/course_api_service.dart' show ApiException;
export 'timetable_repository.dart';

//! Course Repository

class CourseRepository {
  static Future<String?> _getTokenOrNull() async {
    return await TokenStorageService.getAccessToken();
  }

  static const String _notLoggedInMsg =
      'You are not logged in. Please sign in to continue.';

  //! Create Course

  static Future<CourseResult<CourseResponseDto>> createCourse({
    required CreateCourseRequestDto request,
  }) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await CourseApiService.createCourse(
        request: request,
        accessToken: token,
      );
      return CourseSuccess(result);
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

  //! Get Course By ID

  static Future<CourseResult<CourseResponseDto>> getCourseById(
    String id,
  ) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await CourseApiService.getCourseById(
        id: id,
        accessToken: token,
      );
      return CourseSuccess(result);
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

  //! Update Course

  static Future<CourseResult<CourseResponseDto>> updateCourse({
    required String id,
    required UpdateCourseRequestDto request,
  }) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await CourseApiService.updateCourse(
        id: id,
        request: request,
        accessToken: token,
      );
      return CourseSuccess(result);
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

  //! Delete Course

  static Future<CourseResult<void>> deleteCourse(String courseId) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      await CourseApiService.deleteCourse(
        courseId: courseId,
        accessToken: token,
      );
      return const CourseSuccess(null);
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

  //! Get Course Management Details

  static Future<CourseResult<CourseManagementResponseDto>> getManagementDetails(
    String id,
  ) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await CourseApiService.getManagementDetails(
        id: id,
        accessToken: token,
      );
      return CourseSuccess(result);
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
