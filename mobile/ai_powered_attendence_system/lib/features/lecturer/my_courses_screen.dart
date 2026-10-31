import 'package:ai_powered_attendence_system/features/auth/data/models/auth_models.dart';
import 'package:ai_powered_attendence_system/features/auth/data/services/auth_api_service.dart';
import 'package:ai_powered_attendence_system/features/auth/login_screen.dart';
import 'package:ai_powered_attendence_system/features/lecturer/data/services/course_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../core/services/token_storage_service.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'create_edit_course_screen.dart';
import 'data/models/course_models.dart';
import 'requests_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/my_courses_header.dart';

const List<Color> _kCardColors = [Color(0xFFD9E9E4), Color(0xFFFFFACC), Color(0xFFF6E7E8)];

//! My Courses Screen

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final List<CourseDto> _courses = [];

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  //! Load Courses

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      String? token = await TokenStorageService.getAccessToken();
      if (token == null || token.isEmpty) {
        _redirectToLogin();
        return;
      }
      try {
        final fetched = await CourseApiService.getMyCourses(accessToken: token);
        if (mounted) {
          setState(() {
            _courses
              ..clear()
              ..addAll(fetched);
            _isLoading = false;
          });
        }
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          //! Token expired — try refresh
          final refreshToken = await TokenStorageService.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) {
            _redirectToLogin();
            return;
          }
          try {
            final auth = await AuthApiService.refresh(
              RefreshTokenRequestDto(refreshToken: refreshToken),
            );
            await TokenStorageService.saveAuth(
              accessToken: auth.accessToken,
              refreshToken: auth.refreshToken,
              user: auth.user,
            );
            //! Retry with new token
            final fetched = await CourseApiService.getMyCourses(accessToken: auth.accessToken);
            if (mounted) {
              setState(() {
                _courses
                  ..clear()
                  ..addAll(fetched);
                _isLoading = false;
              });
            }
          } catch (_) {
            //! Refresh failed — send to login
            await TokenStorageService.clearAuth();
            _redirectToLogin();
          }
        } else {
          if (mounted) setState(() { _isLoading = false; _error = e.message; });
        }
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  //! Redirect To Login

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  //! Open New Course Screen

  Future<void> _openNewCourse() async {
    final created = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateEditCourseScreen()));
    if (created is CourseResponseDto && mounted) {
      setState(() {
        _courses.insert(0, CourseDto.fromResponse(created));
      });
    }
  }

  //! Open Edit Course Screen

  Future<void> _openEditCourse(CourseDto course) async {
    final updated = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CreateEditCourseScreen(existingCourse: course)));
    if (!mounted) return;
    if (updated is CourseResponseDto) {
      setState(() {
        final index = _courses.indexWhere((c) => c.id == updated.id);
        if (index != -1) {
          _courses[index] = CourseDto.fromResponse(updated);
        }
      });
    } else if (updated == true) {
      setState(() {
        _courses.removeWhere((c) => c.id == course.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = _courses.fold<int>(0, (sum, c) => sum + c.studentCount);
    final semester = 'Fall 2026 . ${_courses.length} courses . $totalStudents students';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: AuthAtmosphere()),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AuthBackButton(
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          MyCoursesHeader(semester: semester, onNewCourse: _openNewCourse),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _loadCourses, child: const Text('Retry')),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      sliver: SliverList.separated(
                        itemCount: _courses.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 15),
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return CourseCard(
                                course: course,
                                cardColor: _kCardColors[index % _kCardColors.length],
                                onEdit: () => _openEditCourse(course),
                                onStudents: () {
                                  Navigator.of(
                                    context,
                                  ).push(MaterialPageRoute(builder: (_) => const RequestsScreen()));
                                },
                              )
                              .animate(delay: (index < 4 ? index * 100 : 0).ms)
                              .fadeIn()
                              .slideY(begin: 0.6, curve: Curves.easeOutCubic);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
