import 'dart:io';
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

  Schedule get schedule => widget.schedule;

  AttendanceNotifier get notifier =>
      ref.read(attendanceProvider(schedule.lectureId).notifier);

  AttendanceState get attendance =>
      ref.watch(attendanceProvider(schedule.lectureId));

  /// 📸 Capture photo
  Future<void> _takePhoto() async {
    if (schedule.lectureStatus != LectureStatus.inProgress) {
      _snack('Lecture is not in progress');
      return;
    }

    if (attendance.submitted) {
      _snack('Attendance already submitted');
      return;
    }

    if (attendance.photoPaths.length >= _maxPhotos) {
      _snack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image == null) return;

    notifier.addPhoto(image.path);
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
  void dispose() {
    notifier.clear(); // 🧹 prevent stale state
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = schedule.lectureStatus;
    final canAct = status == LectureStatus.inProgress && !attendance.submitted;

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

            /// 🔹 PHOTO PREVIEW + DELETE
            if (widget.mode == LectureCardMode.current &&
                attendance.photoPaths.isNotEmpty) ...[
              Text(
                'Photos (${attendance.photoPaths.length}/$_maxPhotos)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: attendance.photoPaths.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Image.file(
                          File(attendance.photoPaths[i]),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => notifier.removePhoto(i),
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
                        enabled:
                            canAct && attendance.photoPaths.length < _maxPhotos,
                        onTap: _takePhoto,
                      ),
                      _ActionButton(
                        label: 'Report\nMass Bunk',
                        enabled: canAct,
                        onTap: () => _confirm(
                          title: 'Report Mass Bunk',
                          message: 'Are you sure you want to report mass bunk?',
                          onConfirm: notifier.submit,
                        ),
                      ),
                      _ActionButton(
                        label: 'Mark\nAll Present',
                        enabled: canAct,
                        onTap: () => _confirm(
                          title: 'Mark All Present',
                          message: 'Are you sure you want to mark all present?',
                          onConfirm: notifier.submit,
                        ),
                      ),
                    ],
                  ),

                  /// 🔹 SUBMIT
                  if (attendance.photoPaths.isNotEmpty && !attendance.submitted)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: attendance.submitting
                            ? null
                            : () => _confirm(
                                title: 'Submit Attendance',
                                message:
                                    'Once submitted, attendance cannot be changed.',
                                onConfirm: notifier.submit,
                              ),
                        child: attendance.submitting
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

                  if (attendance.submitted)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
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
