import 'dart:async';
import 'dart:io';

import '../../../../core/services/token_storage_service.dart';
import '../models/course_models.dart';
import '../services/timetable_api_service.dart';

//! Timetable Repository

class TimetableRepository {
  static Future<String?> _getTokenOrNull() async {
    return await TokenStorageService.getAccessToken();
  }

  static const String _notLoggedInMsg =
      'You are not logged in. Please sign in to continue.';

  //! Get Timetable

  static Future<CourseResult<List<CourseTimetableEntryResponseDto>>> getTimetable(
    String courseId,
  ) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await TimetableApiService.getTimetable(
        courseId: courseId,
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

  //! Create Timetable Entry

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      createTimetableEntry({
    required String courseId,
    required CreateCourseTimetableEntryRequestDto request,
  }) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await TimetableApiService.createTimetableEntry(
        courseId: courseId,
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

  //! Update Timetable Entry

  static Future<CourseResult<CourseTimetableEntryResponseDto>>
      updateTimetableEntry({
    required String courseId,
    required String entryId,
    required CreateCourseTimetableEntryRequestDto request,
  }) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      final result = await TimetableApiService.updateTimetableEntry(
        courseId: courseId,
        entryId: entryId,
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

  //! Delete Timetable Entry

  static Future<CourseResult<void>> deleteTimetableEntry({
    required String courseId,
    required String entryId,
  }) async {
    try {
      final token = await _getTokenOrNull();
      if (token == null || token.isEmpty) {
        return const CourseFailure(_notLoggedInMsg, statusCode: 401);
      }

      await TimetableApiService.deleteTimetableEntry(
        courseId: courseId,
        entryId: entryId,
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
}

