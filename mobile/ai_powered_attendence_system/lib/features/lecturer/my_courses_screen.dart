import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
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
  final List<CourseDto> _courses = [
    // i want to create 10 courses with random data for testing
    CourseDto(
      id: '1',
      name: 'Introduction to Computer Science',
      code: 'CS101',
      department: 'Computer Science',
      description: 'This course provides an introduction to the fundamental concepts of computer science, including algorithms, data structures, and programming languages.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '2',
      name: 'Data Structures and Algorithms',
      code: 'CS201',
      department: 'Computer Science',
      description: 'This course covers the design and analysis of data structures and algorithms, including arrays, linked lists, trees, graphs, sorting, and searching.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '3',
      name: 'Database Systems',
      code: 'CS301',
      department: 'Computer Science',
      description: 'This course introduces the principles of database systems, including data modeling, relational databases, SQL, and database design.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '4',
      name: 'Operating Systems',
      code: 'CS401',
      department: 'Computer Science',
      description: 'This course explores the concepts and design of operating systems, including process management, memory management, file systems, and concurrency.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '5',
      name: 'Computer Networks',
      code: 'CS501',
      department: 'Computer Science',
      description: 'This course covers the fundamentals of computer networking, including network protocols, architectures, and security.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '6',
      name: 'Software Engineering',
      code: 'CS601 ',
      department: 'Computer Science',
      description: 'This course introduces the principles and practices of software engineering, including software development life cycle, requirements analysis, design, testing, and maintenance.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '7',
      name: 'Artificial Intelligence',
      code: 'CS701',
      department: 'Computer Science',
      description: 'This course provides an introduction to artificial intelligence, including search algorithms, knowledge representation, reasoning, and machine learning.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '8',
      name: 'Machine Learning',
      code: 'CS801',
      department: 'Computer Science',
      description: 'This course covers the principles and techniques of machine learning, including supervised and unsupervised learning, neural networks, and deep learning.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '9',
      name: 'Computer Graphics',
      code: 'CS901',
      department: 'Computer Science',
      description: 'This course introduces the principles and techniques of computer graphics, including rendering, modeling, and animation.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
    CourseDto(
      id: '10',
      name: 'Human-Computer Interaction',
      code: 'CS1001',
      department: 'Computer Science',
      description: 'This course explores the principles and techniques of human-computer interaction, including user interface design, usability testing, and user experience.',
      prerequisites: [],
      enrollmentStatus: EnrollmentStatus.open,
      studentCount: 100,
      avgAttendance: 85.5,
      scheduleTime: '',
      scheduleDay: '',
      hall: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
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
