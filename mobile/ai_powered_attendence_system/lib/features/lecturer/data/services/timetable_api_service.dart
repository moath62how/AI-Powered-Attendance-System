import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../core/network/api_config.dart';
import '../../../auth/data/services/auth_api_service.dart' show ApiException;
import '../models/course_models.dart';

export '../../../auth/data/services/auth_api_service.dart' show ApiException;

//! Timetable API Service

class TimetableApiService {
  static const Duration _timeout = Duration(seconds: 25);

  static Map<String, String> _jsonHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

  static String _url(String path) => '${ApiConfig.baseUrl}/$path';

  static void _assertOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw ApiException(
      statusCode: res.statusCode,
      message: 'Timetable request failed (HTTP ${res.statusCode}).',
    );
  }

  //! Get Timetable

  static Future<List<CourseTimetableEntryResponseDto>> getTimetable({
    required String courseId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('courses/$courseId/timetable'));
    final res = await http
        .get(uri, headers: _jsonHeaders(accessToken))
        .timeout(_timeout);

    _assertOk(res);
    final list = jsonDecode(res.body) as List? ?? [];
    return list
        .map((e) =>
            CourseTimetableEntryResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //! Create Timetable Entry

  static Future<CourseTimetableEntryResponseDto> createTimetableEntry({
    required String courseId,
    required CreateCourseTimetableEntryRequestDto request,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('courses/$courseId/timetable'));
    final res = await http
        .post(
          uri,
          headers: _jsonHeaders(accessToken),
          body: jsonEncode(request.toJson()),
        )
        .timeout(_timeout);

    _assertOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CourseTimetableEntryResponseDto.fromJson(body);
  }

  //! Update Timetable Entry

  static Future<CourseTimetableEntryResponseDto> updateTimetableEntry({
    required String courseId,
    required String entryId,
    required CreateCourseTimetableEntryRequestDto request,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('courses/$courseId/timetable/$entryId'));
    final res = await http
        .put(
          uri,
          headers: _jsonHeaders(accessToken),
          body: jsonEncode(request.toJson()),
        )
        .timeout(_timeout);

    _assertOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return CourseTimetableEntryResponseDto.fromJson(body);
  }

  //! Delete Timetable Entry

  static Future<void> deleteTimetableEntry({
    required String courseId,
    required String entryId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(_url('courses/$courseId/timetable/$entryId'));
    final res = await http
        .delete(uri, headers: _jsonHeaders(accessToken))
        .timeout(_timeout);

    _assertOk(res);
  }
}
