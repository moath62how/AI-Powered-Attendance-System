import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/theme/app_colors.dart';
import '../../widgets/auth_atmosphere.dart';
import '../../widgets/auth_back_button.dart';
import 'data/models/course_models.dart';
import 'data/repositories/course_repository.dart';
import 'widgets/create_edit_course/course_form_field.dart';
import 'widgets/create_edit_course/course_image_card.dart';
import 'widgets/create_edit_course/create_edit_course_actions.dart';
import 'widgets/create_edit_course/create_edit_header.dart';
import 'widgets/create_edit_course/enrollment_status_card.dart';
import 'widgets/create_edit_course/prerequisites_section.dart';

//! Create & Edit Course Screen

class CreateEditCourseScreen extends StatefulWidget {
  final CourseDto? existingCourse;

  const CreateEditCourseScreen({super.key, this.existingCourse});

  bool get isEditing => existingCourse != null;

  @override
  State<CreateEditCourseScreen> createState() => _CreateEditCourseScreenState();
}

class _CreateEditCourseScreenState extends State<CreateEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _departmentController;
  late final TextEditingController _descriptionController;

  late EnrollmentStatus _enrollmentStatus;
  late List<Prerequisite> _prerequisites;
  File? _imageFile;
  String? _initialImageUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCourse;
    _nameController = TextEditingController(text: c?.name ?? '');
    _codeController = TextEditingController(text: c?.code ?? '');
    _departmentController = TextEditingController(text: c?.department ?? '');
    _descriptionController = TextEditingController(text: c?.description ?? '');
    _enrollmentStatus = c?.enrollmentStatus ?? EnrollmentStatus.open;
    _prerequisites = List.from(c?.prerequisites ?? []);
    _initialImageUrl = c?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _departmentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  //! Image Picker

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.ink),
                title: Text('Take Photo', style: GoogleFonts.inter(fontSize: 14)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.ink),
                title: Text('Choose from Gallery', style: GoogleFonts.inter(fontSize: 14)),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppColors.wrong),
        );
      }
    }
  }

  //! Save Course

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    if (widget.isEditing) {
      final updateReq = UpdateCourseRequestDto(
        courseName: _nameController.text.trim(),
        courseCode: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        semester: 'Fall 2026',
        enrollmentMode: _enrollmentStatus.toBackendMode(),
        image: _imageFile,
      );

      final result = await CourseRepository.updateCourse(
        id: widget.existingCourse!.id,
        request: updateReq,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (result) {
        case CourseSuccess():
          Navigator.of(context).pop(result.data);
        case CourseFailure():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: AppColors.wrong));
      }
    } else {
      final createReq = CreateCourseRequestDto(
        courseName: _nameController.text.trim(),
        courseCode: _codeController.text.trim(),
        description: _descriptionController.text.trim(),
        semester: 'Fall 2026',
        image: _imageFile,
      );

      final result = await CourseRepository.createCourse(request: createReq);

      if (!mounted) return;
      setState(() => _isLoading = false);

      switch (result) {
        case CourseSuccess():
          Navigator.of(context).pop(result.data);
        case CourseFailure():
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: AppColors.wrong));
      }
    }
  }

  //! Delete Course

  Future<void> _onDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Course?',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This will permanently delete "${_nameController.text}". This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete', style: GoogleFonts.inter(color: AppColors.wrong)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    final result = await CourseRepository.deleteCourse(widget.existingCourse!.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case CourseSuccess():
        Navigator.of(context).pop(true);
      case CourseFailure():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message), backgroundColor: AppColors.wrong));
    }
  }

  //! Add Prerequisite Dialog

  Future<void> _showAddPrerequisiteDialog() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Prerequisite',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. CS 103 or Math 402',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              'Add',
              style: GoogleFonts.inter(color: AppColors.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        _prerequisites.add(Prerequisite(courseCode: code, minimumGrade: ''));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AuthAtmosphere()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const AuthBackButton(),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: CreateEditHeader(
                                    isEditing: widget.isEditing,
                                    existingCourse: widget.existingCourse,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildForm(),
                            const SizedBox(height: 12),
                            EnrollmentStatusCard(
                              currentStatus: _enrollmentStatus,
                              onStatusChanged: (status) =>
                                  setState(() => _enrollmentStatus = status),
                            ),
                            const SizedBox(height: 12),
                            CreateEditCourseActions(
                              isEditing: widget.isEditing,
                              isLoading: _isLoading,
                              onSave: _isLoading ? null : _onSave,
                              onDelete: _isLoading ? null : _onDelete,
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseImageCard(
              imageFile: _imageFile,
              initialImageUrl: _initialImageUrl,
              onPickImage: _pickImage,
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CourseFormField(
                    label: 'Name',
                    controller: _nameController,
                    hint: 'Data Structure',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CourseFormField(
                    label: 'Code',
                    controller: _codeController,
                    hint: 'CS301',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CourseFormField(
              label: 'Department',
              controller: _departmentController,
              hint: 'Computer Science',
              hasDropdownIndicator: true,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            CourseFormField(
              label: 'Description',
              controller: _descriptionController,
              hint: 'Array, Linked List ...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            PrerequisitesSection(
              prerequisites: _prerequisites,
              onRemove: (index) => setState(() => _prerequisites.removeAt(index)),
              onAdd: _showAddPrerequisiteDialog,
            ),
          ],
        ),
      ),
    );
  }
}
