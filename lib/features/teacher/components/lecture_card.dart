import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/entities/schedule.dart';
import '../presentation/lecture_card_mode.dart';

class LectureCard extends StatefulWidget {
  final Schedule schedule;
  final LectureCardMode mode;

  const LectureCard({super.key, required this.schedule, required this.mode});

  @override
  State<LectureCard> createState() => _LectureCardState();
}

class _LectureCardState extends State<LectureCard> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _photos = [];
  bool _isSubmitting = false;
  bool _attendanceSubmitted = false;
  static const int _maxPhotos = 6;

  Schedule get schedule => widget.schedule;

  /// 🔹 Open camera and take photo
  Future<void> _takePhoto() async {
    // 🔒 Block if attendance already submitted
    if (_attendanceSubmitted) {
      _showSnack('Attendance already marked for this lecture');
      return;
    }

    // 🔒 Block if max photos reached
    if (_photos.length >= _maxPhotos) {
      _showSnack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _photos.add(File(image.path));
    });
  }

  /// 🔹 Confirmation dialog
  Future<void> _confirm({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
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

    if (result == true) {
      onConfirm();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final status = schedule.lectureStatus;

    return Card(
      color: Colors.white70,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              "Section: ${schedule.section}",
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

            /// 🔹 PHOTO PREVIEW + COUNT (CURRENT CLASS ONLY)
            if (widget.mode == LectureCardMode.current &&
                _photos.isNotEmpty) ...[
              Text(
                'Photos: ${_photos.length} / $_maxPhotos',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.file(
                      _photos[i],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            /// 🔹 ACTIONS
            _buildActions(status),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(LectureStatus status) {
    switch (widget.mode) {
      /// 🔹 CURRENT CLASS
      case LectureCardMode.current:
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  label: "Upload\nPhoto",
                  enabled:
                      status == LectureStatus.inProgress &&
                      !_attendanceSubmitted,
                  onTap: _takePhoto,
                ),
                _ActionButton(
                  label: "Report\nMass Bunk",
                  enabled:
                      status == LectureStatus.inProgress &&
                      !_attendanceSubmitted,
                  onTap: () {
                    _confirm(
                      title: 'Report Mass Bunk',
                      message: 'Are you sure you want to report mass bunk?',
                      onConfirm: () {
                        setState(() {
                          _attendanceSubmitted = true;
                        });
                        print('Report Mass Bunk API call');
                      },
                    );
                  },
                ),
                _ActionButton(
                  label: "Mark\nAll Present",
                  enabled:
                      status == LectureStatus.inProgress &&
                      !_attendanceSubmitted,
                  onTap: () {
                    _confirm(
                      title: 'Mark All Present',
                      message:
                          'Are you sure you want to mark all students present?',
                      onConfirm: () {
                        setState(() {
                          _attendanceSubmitted = true;
                        });
                        print('Mark All Present API call');
                      },
                    );
                  },
                ),
              ],
            ),

            /// 🔹 SUBMIT BUTTON
            if (_photos.isNotEmpty && !_attendanceSubmitted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          setState(() {
                            _isSubmitting = true;
                          });

                          // 🔹 Simulate API call delay
                          await Future.delayed(const Duration(seconds: 2));

                          print('Submitting attendance');
                          print({
                            'courseCode': schedule.courseCode,
                            'section': schedule.section,
                            'photoCount': _photos.length,
                          });

                          setState(() {
                            _isSubmitting = false;
                            _attendanceSubmitted = true;
                          });
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Attendance'),
                ),
              ),
          ],
        );

      /// 🔹 ALL / UPCOMING
      case LectureCardMode.all:
      case LectureCardMode.upcoming:
        return Align(
          alignment: Alignment.center,
          child: _ActionButton(
            label: "Cancel Lecture",
            isDanger: true,
            enabled: status == LectureStatus.pending,
            onTap: () {
              _confirm(
                title: 'Cancel Lecture',
                message: 'Are you sure you want to cancel this lecture?',
                onConfirm: () {
                  print('Cancel Lecture API call');
                },
              );
            },
          ),
        );
    }
  }
}

/// 🔹 Status text
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

    final color = status == LectureStatus.inProgress
        ? Colors.green
        : Colors.black;

    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }
}

/// 🔹 Info item
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

/// 🔹 Action button
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
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}
