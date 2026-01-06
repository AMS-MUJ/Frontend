import 'dart:io';
import 'package:ams_try2/core/utils/excel_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/schedule.dart';
import '../presentation/lecture_card_mode.dart';
import '../presentation/providers/attendance_provider.dart';

class LectureCard extends ConsumerStatefulWidget {
  final Schedule schedule;
  final LectureCardMode mode;

  const LectureCard({super.key, required this.schedule, required this.mode});

  @override
  ConsumerState<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends ConsumerState<LectureCard> {
  final ImagePicker _picker = ImagePicker();
  static const int _maxPhotos = 6;

  /// 🔹 LOCAL PHOTO STATE (only change)
  final List<String> _photoPaths = [];

  Schedule get schedule => widget.schedule;

  AttendanceNotifier get notifier => ref.read(attendanceProvider.notifier);

  AttendanceState get attendance => ref.watch(attendanceProvider);

  /// 📸 Capture photo
  Future<void> _takePhoto() async {
    if (schedule.lectureStatus != LectureStatus.inProgress) {
      _snack('Lecture is not in progress');
      return;
    }

    if (_photoPaths.length >= _maxPhotos) {
      _snack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _photoPaths.add(image.path);
    });
  }

  /// ✅ Submit attendance
  Future<void> _submitAttendance() async {
    if (schedule.lectureId.isEmpty) {
      _snack('Invalid lecture ID');
      return;
    }

    await notifier.submitAttendance(schedule.lectureId, _photoPaths);

    final state = ref.read(attendanceProvider);

    if (state.error != null) {
      _snack(state.error!);
      return;
    }

    final attendance = state.attendance;
    if (attendance == null) {
      _snack('Attendance submission failed');
      return;
    }

    await generateAttendanceExcel(attendance);
    _snack('Attendance Excel generated successfully');
  }

  /// ✅ Confirmation dialog
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
    final status = schedule.lectureStatus;
    final canAct = status == LectureStatus.inProgress;
    final loading = attendance.loading;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 TITLE + STATUS
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

            /// 🔹 INFO ROW
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
                _photoPaths.isNotEmpty) ...[
              Text(
                'Photos (${_photoPaths.length}/$_maxPhotos)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPaths.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Image.file(
                          File(_photoPaths[i]),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _photoPaths.removeAt(i);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
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

            /// 🔹 ACTIONS
            if (widget.mode == LectureCardMode.current)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        label: 'Upload\nPhoto',
                        enabled: canAct && _photoPaths.length < _maxPhotos,
                        onTap: _takePhoto,
                      ),
                      _ActionButton(
                        label: 'Report\nMass Bunk',
                        enabled: canAct,
                        onTap: () => _confirm(
                          title: 'Report Mass Bunk',
                          message: 'Are you sure you want to report mass bunk?',
                          onConfirm: _submitAttendance,
                        ),
                      ),
                      _ActionButton(
                        label: 'Mark\nAll Present',
                        enabled: canAct,
                        onTap: () => _confirm(
                          title: 'Mark All Present',
                          message: 'Are you sure you want to mark all present?',
                          onConfirm: _submitAttendance,
                        ),
                      ),
                    ],
                  ),

                  /// 🔹 SUBMIT
                  if (_photoPaths.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: loading
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
                ],
              ),

            /// 🔹 CANCEL (ALL / UPCOMING)
            if (widget.mode != LectureCardMode.current)
              Align(
                alignment: Alignment.center,
                child: _ActionButton(
                  label: 'Cancel Lecture',
                  isDanger: true,
                  enabled: status == LectureStatus.pending,
                  onTap: () => _confirm(
                    title: 'Cancel Lecture',
                    message: 'Are you sure you want to cancel this lecture?',
                    onConfirm: () {
                      debugPrint('Cancel lecture API call');
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 STATUS TEXT
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

/// 🔹 INFO ITEM
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

/// 🔹 ACTION BUTTON
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
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
