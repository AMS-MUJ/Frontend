import 'dart:io';

import 'package:ams_try2/core/utils/attendance_submission_store.dart';
import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:ams_try2/features/teacher/presentation/lecture_card_mode.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class LectureCard extends ConsumerStatefulWidget {
  final Schedule schedule;
  final LectureCardMode mode;

  const LectureCard({super.key, required this.schedule, required this.mode});

  @override
  ConsumerState<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends ConsumerState<LectureCard> {
  static const int _maxPhotos = 6;
  final ImagePicker _picker = ImagePicker();

  /// 📸 Local photo paths
  final List<String> _photoPaths = [];

  /// ✅ Persistent submission state
  bool _submitted = false;
  bool _checkingSubmission = true;

  Schedule get schedule => widget.schedule;

  AttendanceNotifier get notifier =>
      ref.read(attendanceProvider(schedule.lectureId).notifier);

  AttendanceState get attendanceState =>
      ref.watch(attendanceProvider(schedule.lectureId));

  @override
  void initState() {
    super.initState();
    _loadSubmissionStatus();
  }

  Future<void> _loadSubmissionStatus() async {
    final submitted = await AttendanceSubmissionStore.isSubmitted(
      schedule.lectureId,
    );

    if (!mounted) return;

    setState(() {
      _submitted = submitted;
      _checkingSubmission = false;
    });
  }

  /// 🚀 Submit attendance
  Future<void> _submitAttendance() async {
    if (schedule.lectureId.isEmpty) {
      _snack('Invalid lecture ID');
      return;
    }

    await notifier.submitAttendance(_photoPaths);

    final state = ref.read(attendanceProvider(schedule.lectureId));

    if (state.error != null) {
      _snack(state.error!);
      return;
    }

    if (state.attendance == null) {
      _snack('Attendance submission failed');
      return;
    }

    debugPrint('🧪 Attendance rows: ${state.attendance!.attendance.length}');

    await AttendanceSubmissionStore.markSubmitted(schedule.lectureId);

    if (!mounted) return;

    setState(() {
      _submitted = true;
    });

    _snack('Attendance submitted successfully');
  }

  /// 📷 Pick image
  Future<void> _pickImage(ImageSource source) async {
    if (_photoPaths.length >= _maxPhotos) {
      _snack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _photoPaths.add(image.path);
    });
  }

  /// 📷 Image source picker
  Future<void> _showImageSourcePicker() async {
    if (schedule.lectureStatus != LectureStatus.inProgress) {
      _snack('Lecture is not in progress');
      return;
    }

    if (_submitted) {
      _snack('Attendance already submitted');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔔 Confirmation dialog
  Future<void> _confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (ok == true) onConfirm();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSubmission) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final status = schedule.lectureStatus;
    final canAct = status == LectureStatus.inProgress && !_submitted;
    final loading = attendanceState.loading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    schedule.subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusText(status),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              schedule.courseCode,
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Section: ${schedule.section}',
              style: const TextStyle(color: Colors.grey),
            ),

            const Divider(height: 20),

            /// 🔹 INFO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(Icons.access_time, schedule.time),
                _InfoItem(Icons.people, '${schedule.totalStudents} Students'),
                _InfoItem(Icons.location_on, schedule.room),
              ],
            ),

            const SizedBox(height: 14),

            /// 🔹 PHOTO PREVIEW
            if (widget.mode == LectureCardMode.current &&
                _photoPaths.isNotEmpty)
              _PhotoPreview(
                paths: _photoPaths,
                onRemove: (i) {
                  setState(() {
                    _photoPaths.removeAt(i);
                  });
                },
              ),

            /// 🔹 ACTIONS
            if (widget.mode == LectureCardMode.current)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionButton(
                    label: 'Upload Photo',
                    enabled: canAct && _photoPaths.length < _maxPhotos,
                    onTap: _showImageSourcePicker,
                  ),
                  _ActionButton(
                    label: 'Report Mass Bunk',
                    isDanger: true,
                    enabled: canAct,
                    onTap: () => _confirm(
                      title: 'Report Mass Bunk',
                      message: 'Are you sure you want to report mass bunk?',
                      onConfirm: _submitAttendance,
                    ),
                  ),
                  _ActionButton(
                    label: 'Mark All Present',
                    enabled: canAct,
                    onTap: () => _confirm(
                      title: 'Mark All Present',
                      message: 'Are you sure you want to mark all present?',
                      onConfirm: _submitAttendance,
                    ),
                  ),
                  if (_photoPaths.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: loading || _submitted
                            ? null
                            : () => _confirm(
                                title: 'Submit Attendance',
                                message:
                                    'Once submitted, attendance cannot be changed.',
                                onConfirm: _submitAttendance,
                              ),
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit Attendance'),
                      ),
                    ),
                  if (_submitted)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Attendance Submitted',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- SMALL WIDGETS ----------------

class _PhotoPreview extends StatelessWidget {
  final List<String> paths;
  final void Function(int index) onRemove;

  const _PhotoPreview({required this.paths, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${paths.length}/6)',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: paths.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  Image.file(
                    File(paths[i]),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _StatusText extends StatelessWidget {
  final LectureStatus status;

  const _StatusText(this.status);

  @override
  Widget build(BuildContext context) {
    final text = {
      LectureStatus.pending: 'Pending',
      LectureStatus.inProgress: 'In Progress',
      LectureStatus.completed: 'Completed',
    }[status]!;

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: status == LectureStatus.inProgress ? Colors.green : Colors.black,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDanger;
  final bool enabled;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isDanger = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: enabled ? onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: enabled
            ? (isDanger ? Colors.red : Colors.black)
            : Colors.grey,
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
