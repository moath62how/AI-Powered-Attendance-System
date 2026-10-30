import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'create_edit_course_screen.dart';
import 'data/models/course_models.dart';
import 'requests_screen.dart';
import 'widgets/course_card.dart';
import 'widgets/my_courses_header.dart';

const List<Color> _kCardColors = [
  Color(0xFFD9E9E4),
  Color(0xFFFFFACC),
  Color(0xFFF6E7E8),
];

//! My Courses Screen

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final List<CourseDto> _courses = [
    const CourseDto(
      id: '1',
      name: 'Data Structures',
      code: 'CS301',
      department: 'CS',
      description: 'Array, Linked List ...',
      prerequisites: [
        Prerequisite(courseCode: 'CS 103', minimumGrade: ''),
        Prerequisite(courseCode: 'Math 402', minimumGrade: ''),
      ],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 186,
      avgAttendance: 84,
      scheduleTime: '09:00 AM',
      scheduleDay: 'Sunday',
      hall: 'B2',
    ),
    const CourseDto(
      id: '2',
      name: 'Algorithms',
      code: 'CS302',
      department: 'CS',
      description: 'Sorting, Graphs ...',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 142,
      avgAttendance: 79,
      scheduleTime: '11:00 AM',
      scheduleDay: 'Tuesday',
      hall: 'A3',
    ),
    const CourseDto(
      id: '3',
      name: 'Operating Systems',
      code: 'CS401',
      department: 'CS',
      description: 'Processes, Memory ...',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.closed,
      studentCount: 84,
      avgAttendance: 91,
      scheduleTime: '01:00 PM',
      scheduleDay: 'Thursday',
      hall: 'C1',
    ),
  ];

  //! Open New Course Screen

  Future<void> _openNewCourse() async {
    final created = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CreateEditCourseScreen(),
      ),
    );
    if (created is CourseResponseDto && mounted) {
      setState(() {
        _courses.insert(0, CourseDto.fromResponse(created));
      });
    }
  }

  //! Open Edit Course Screen

  Future<void> _openEditCourse(CourseDto course) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEditCourseScreen(existingCourse: course),
      ),
    );
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
    final totalStudents =
        _courses.fold<int>(0, (sum, c) => sum + c.studentCount);
    final semester =
        'Fall 2026 . ${_courses.length} courses . $totalStudents students';

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
                          MyCoursesHeader(
                            semester: semester,
                            onNewCourse: _openNewCourse,
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RequestsScreen(),
                              ),
                            );
                          },
                        );
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
