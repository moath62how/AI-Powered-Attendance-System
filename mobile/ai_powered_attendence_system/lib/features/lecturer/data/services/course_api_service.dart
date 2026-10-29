import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../models/course_models.dart';
import 'timetable_api_service.dart';

export '../../../auth/data/services/auth_api_service.dart' show ApiException;
export 'timetable_api_service.dart';

//! Course API Service

class CourseApiService {
  static const Duration _timeout = Duration(seconds: 25);

  //! Helpers

  static Map<String, String> _jsonHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  static String _url(String path) => '${ApiConfig.baseUrl}/$path';

  static String _parseError(String body, int statusCode) {
    try {
      final map = jsonDecode(body);
      if (map is Map) {
        if (map.containsKey('errors')) {
          final errors = map['errors'];
          if (errors is Map) {
            final messages = errors.values
                .expand<String>((v) => (v as List).cast<String>())
                .toList();
            if (messages.isNotEmpty) return messages.join(' ');
          } else if (errors is List) {
            final messages = errors
                .map((e) => e is Map ? (e['error'] ?? '').toString() : '')
                .where((s) => s.isNotEmpty)
                .toList();
            if (messages.isNotEmpty) return messages.join(' ');
          }
        }
        final msg = map['detail'] ?? map['title'] ?? map['message'];
        if (msg != null) return msg.toString();
      }
    } catch (_) {}
    return _defaultMessage(statusCode);
  }

  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid course or timetable data. Please check your inputs.';
      case 401:
        return 'Session expired. Please log in again.';
      case 403:
        return 'You do not have permission to manage this course.';
      case 404:
        return 'Course or timetable entry not found.';
      case 409:
        return 'A course code or timetable conflict was detected.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Unexpected server response (HTTP $statusCode).';
    }
  }

  static void _assertOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final msg = _parseError(res.body, res.statusCode);
    throw ApiException(statusCode: res.statusCode, message: msg);
  }

  static Future<http.Response> _sendMultipart(
    String method,
    String path, {
    required String accessToken,
    required Map<String, String> fields,
    File? imageFile,
    String? imagePath,
  }) async {
    final uri = Uri.parse(_url(path));
    final request = http.MultipartRequest(method, uri);

    request.headers['Authorization'] = 'Bearer $accessToken';
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

    final pathToFile = imageFile?.path ?? imagePath;
    if (pathToFile != null && pathToFile.isNotEmpty) {
      final file = File(pathToFile);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('Image', pathToFile),
        );
      }
    }

    final streamed = await request.send().timeout(_timeout);
    var res = await http.Response.fromStream(streamed);

    if ((res.statusCode == 307 || res.statusCode == 308) &&
        res.headers.containsKey('location')) {
      var location = res.headers['location']!;
      try {
        if (Platform.isAndroid) {
          location = location
              .replaceFirst('://localhost:', '://10.0.2.2:')
              .replaceFirst('://127.0.0.1:', '://10.0.2.2:');
        }
      } catch (_) {}

      final retryRequest = http.MultipartRequest(method, Uri.parse(location));
      retryRequest.headers.addAll(request.headers);
      retryRequest.fields.addAll(fields);
      if (pathToFile != null && pathToFile.isNotEmpty) {
        retryRequest.files.add(
          await http.MultipartFile.fromPath('Image', pathToFile),
        );
      }
      final retryStreamed = await retryRequest.send().timeout(_timeout);
      res = await http.Response.fromStream(retryStreamed);
    }

    _assertOk(res);
    return res;
  }

  //! Create Course

  static Future<CourseResponseDto> createCourse({
    required CreateCourseRequestDto request,
    required String accessToken,
  }) async {
    final fields = <String, String>{
      'CourseName': request.courseName.trim(),
      'CourseCode': request.courseCode.trim(),
      'Description': request.description.trim(),
      'Semester': request.semester.trim(),
    };

    final res = await _sendMultipart(
      'POST',
      'Courses',
      accessToken: accessToken,
      fields: fields,
      imageFile: request.image,
      imagePath: request.imagePath,
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CourseResponseDto.fromJson(body);
  }

  //! Get Course By ID

  static Future<CourseResponseDto> getCourseById({
    required String id,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('Courses/$id'));
    final res = await http
        .get(uri, headers: _jsonHeaders(accessToken))
        .timeout(_timeout);

    _assertOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CourseResponseDto.fromJson(body);
  }

  //! Update Course

  static Future<CourseResponseDto> updateCourse({
    required String id,
    required UpdateCourseRequestDto request,
    required String accessToken,
  }) async {
    final fields = <String, String>{};
    if (request.courseName != null) {
      fields['CourseName'] = request.courseName!.trim();
    }
    if (request.courseCode != null) {
      fields['CourseCode'] = request.courseCode!.trim();
    }
    if (request.description != null) {
      fields['Description'] = request.description!.trim();
    }
    if (request.semester != null) {
      fields['Semester'] = request.semester!.trim();
    }
    if (request.enrollmentMode != null) {
      fields['EnrollmentMode'] = request.enrollmentMode!;
    }

    final res = await _sendMultipart(
      'PATCH',
      'Courses/$id',
      accessToken: accessToken,
      fields: fields,
      imageFile: request.image,
      imagePath: request.imagePath,
    );

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body.containsKey('course') && body['course'] is Map) {
      return CourseResponseDto.fromJson(
        body['course'] as Map<String, dynamic>,
      );
    }
    return CourseResponseDto.fromJson(body);
  }

  //! Delete Course

  static Future<void> deleteCourse({
    required String courseId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('Courses/$courseId'));
    final res = await http
        .delete(uri, headers: _jsonHeaders(accessToken))
        .timeout(_timeout);

    _assertOk(res);
  }

  //! Get Course Management Details

  static Future<CourseManagementResponseDto> getManagementDetails({
    required String id,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('Courses/$id/management'));
    final res = await http
        .get(uri, headers: _jsonHeaders(accessToken))
        .timeout(_timeout);

    _assertOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CourseManagementResponseDto.fromJson(body);
  }

  //! Timetable Delegations

  static Future<List<CourseTimetableEntryResponseDto>> getTimetable({
    required String courseId,
    required String accessToken,
  }) =>
      TimetableApiService.getTimetable(
        courseId: courseId,
        accessToken: accessToken,
      );

  static Future<CourseTimetableEntryResponseDto> createTimetableEntry({
    required String courseId,
    required CreateCourseTimetableEntryRequestDto request,
    required String accessToken,
  }) =>
      TimetableApiService.createTimetableEntry(
        courseId: courseId,
        request: request,
        accessToken: accessToken,
      );

  static Future<CourseTimetableEntryResponseDto> updateTimetableEntry({
    required String courseId,
    required String entryId,
    required CreateCourseTimetableEntryRequestDto request,
    required String accessToken,
  }) =>
      TimetableApiService.updateTimetableEntry(
        courseId: courseId,
        entryId: entryId,
        request: request,
        accessToken: accessToken,
      );

  static Future<void> deleteTimetableEntry({
    required String courseId,
    required String entryId,
    required String accessToken,
  }) =>
      TimetableApiService.deleteTimetableEntry(
        courseId: courseId,
        entryId: entryId,
        accessToken: accessToken,
      );
}
