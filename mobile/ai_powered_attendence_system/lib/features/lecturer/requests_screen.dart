import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'data/models/course_models.dart';
import 'widgets/request_card.dart';
import 'widgets/requests/request_tab.dart';

//! Requests Screen

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<StudentRequestDto> _enrollmentRequests = [
    const StudentRequestDto(
      id: '1',
      studentName: 'Omar Hassan',
      studentId: '232000644',
      initials: 'OH',
      type: RequestType.enrollment,
      status: RequestStatus.pending,
      timeAgo: '2h ago',
      courseInfo: 'CS301 . Computer Science',
      primaryInfo: 'Lecture A, Section 1',
      secondaryInfo: 'prerequisites met',
    ),
    const StudentRequestDto(
      id: '2',
      studentName: 'Nour Adel',
      studentId: '232000666',
      initials: 'NA',
      type: RequestType.enrollment,
      status: RequestStatus.pending,
      timeAgo: '5h ago',
      courseInfo: 'CS301 . Computer Science',
      primaryInfo: 'Lecture B, Section 2',
      secondaryInfo: 'prerequisites met',
    ),
    const StudentRequestDto(
      id: '3',
      studentName: 'Mariam Saeed',
      studentId: '232000655',
      initials: 'MS',
      type: RequestType.enrollment,
      status: RequestStatus.pending,
      timeAgo: 'Yesterday',
      courseInfo: 'CS301 . Computer Science',
      primaryInfo: 'Lecture A, Section 1',
      secondaryInfo: 'missing CS104',
    ),
    const StudentRequestDto(
      id: '4',
      studentName: 'Sara Kama',
      studentId: '232000785',
      initials: 'SK',
      type: RequestType.enrollment,
      status: RequestStatus.pending,
      timeAgo: 'Yesterday',
      courseInfo: 'CS301 . Computer Science',
      primaryInfo: 'Lecture B, Section 2',
      secondaryInfo: 'prerequisites met',
    ),
  ];

  final List<StudentRequestDto> _deviceRequests = [
    const StudentRequestDto(
      id: '5',
      studentName: 'Ahmed Anwar',
      studentId: '232000644',
      initials: 'AA',
      type: RequestType.deviceChange,
      status: RequestStatus.pending,
      timeAgo: '20 min ago',
      courseInfo: 'Samsung A54 to iPhone 13',
      primaryInfo: '"My old phone was broken"',
      secondaryInfo: '',
    ),
  ];

  final List<StudentRequestDto> _correctionRequests = [
    const StudentRequestDto(
      id: '6',
      studentName: 'Salma Fathy',
      studentId: '232000644',
      initials: 'SF',
      type: RequestType.attendanceCorrection,
      status: RequestStatus.pending,
      timeAgo: '1h ago',
      courseInfo: 'CS 301 · Lecture, Tue 20 Oct',
      primaryInfo: 'marked Absent',
      secondaryInfo: '"I was present, the app didn\'t record it"',
    ),
    const StudentRequestDto(
      id: '7',
      studentName: 'Jana Yaser',
      studentId: '232000644',
      initials: 'JY',
      type: RequestType.attendanceCorrection,
      status: RequestStatus.pending,
      timeAgo: '3d ago',
      courseInfo: 'CS 301 · Section 2, Mon 19 Oct',
      primaryInfo: 'marked Late',
      secondaryInfo: '"I had an approved excuse"',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //! Accept Request

  void _handleAccept(String id, RequestType type) {
    setState(() {
      _removeRequest(id, type);
    });
  }

  //! Decline Request

  void _handleDecline(String id, RequestType type) {
    setState(() {
      _removeRequest(id, type);
    });
  }

  void _removeRequest(String id, RequestType type) {
    switch (type) {
      case RequestType.enrollment:
        _enrollmentRequests.removeWhere((r) => r.id == id);
      case RequestType.deviceChange:
        _deviceRequests.removeWhere((r) => r.id == id);
      case RequestType.attendanceCorrection:
        _correctionRequests.removeWhere((r) => r.id == id);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthBackButton(),
                        const SizedBox(height: 18),
                        _buildPageHeader(),
                        const SizedBox(height: 20),
                        _buildTabBar(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRequestList(
                          requests: _enrollmentRequests,
                          acceptLabel: 'Accept',
                          declineLabel: 'Decline',
                        ),
                        _buildRequestList(
                          requests: _deviceRequests,
                          acceptLabel: 'Approve',
                          declineLabel: 'Reject',
                        ),
                        _buildRequestList(
                          requests: _correctionRequests,
                          acceptLabel: 'Mark Present',
                          declineLabel: 'Keep Status',
                        ),
                      ],
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

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requests',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Students waiting on your decision',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEAE5).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelPadding: EdgeInsets.zero,
        tabs: [
          RequestTab(
            label: 'Enrollment',
            count: _enrollmentRequests.length,
            tabController: _tabController,
            index: 0,
          ),
          RequestTab(
            label: 'Device\nChanges',
            count: _deviceRequests.length,
            tabController: _tabController,
            index: 1,
          ),
          RequestTab(
            label: 'Attendance\ncorrections',
            count: _correctionRequests.length,
            tabController: _tabController,
            index: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList({
    required List<StudentRequestDto> requests,
    required String acceptLabel,
    required String declineLabel,
  }) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No pending requests',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = requests[index];
        return RequestCard(
          request: req,
          acceptLabel: acceptLabel,
          declineLabel: declineLabel,
          onAccept: () => _handleAccept(req.id, req.type),
          onDecline: () => _handleDecline(req.id, req.type),
        );
      },
    );
  }
}
