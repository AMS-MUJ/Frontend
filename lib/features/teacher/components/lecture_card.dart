import 'dart:async';
import 'dart:io';
import 'package:ams_try2/core/services/attendance_submission_manager.dart';
import 'package:ams_try2/features/teacher/domain/entities/schedule.dart';
import 'package:ams_try2/features/teacher/presentation/lecture_card_mode.dart';
import 'package:ams_try2/features/teacher/presentation/providers/attendance_provider.dart';
import 'package:ams_try2/features/teacher/presentation/providers/filtered_schedule_provider.dart';
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
  final List<String> _photoPaths = [];

  // Only local UI state — submission truth comes from schedule.attendanceMarked
  bool _isSubmitting = false;

  StreamSubscription<SubmissionResult>? _resultSub;
  bool _subscribed = false;

  Schedule get schedule => widget.schedule;

  // Derived directly from backend — no local cache needed
  bool get _submitted => schedule.attendanceMarked;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      _subscribed = true;
      _listenToResults();
    }
  }

  @override
  void dispose() {
    _resultSub?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Result stream — only drives upload spinner and error snacks.
  // Actual "submitted" state comes from backend via schedule refresh.
  // -------------------------------------------------------------------------
  void _listenToResults() {
    _resultSub?.cancel();

    if (schedule.lectureId.isEmpty) {
      debugPrint(
        '⚠️ LectureCard: empty lectureId for ${schedule.subject}, '
        'skipping result subscription',
      );
      return;
    }

    final myLectureId = schedule.lectureId;

    _resultSub = ref
        .read(attendanceSubmissionManagerProvider)
        .results
        .where((r) => r.lectureId == myLectureId)
        .listen((result) {
          if (!mounted) return;

          if (result.success) {
            setState(() {
              _isSubmitting = false;
              _photoPaths.clear();
            });
            // Invalidate schedule — backend now returns is_marked: true
            // which flows into schedule.attendanceMarked and rebuilds the UI
            ref.invalidate(filteredScheduleProvider);
            _snack('Attendance submitted successfully');
          } else {
            setState(() => _isSubmitting = false);
            ref.read(attendanceProvider(myLectureId).notifier).reset();
            _snack('Upload failed: ${result.error ?? 'unknown error'}');
          }
        });
  }

  // -------------------------------------------------------------------------
  // Submit
  // -------------------------------------------------------------------------
  Future<void> _submitAttendance() async {
    if (_isSubmitting || _submitted) return;

    if (schedule.lectureId.isEmpty) {
      _snack('Invalid lecture ID');
      return;
    }

    if (_photoPaths.isEmpty) {
      _snack('Please upload at least one photo');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(attendanceProvider(schedule.lectureId).notifier)
          .submitAttendance(List.of(_photoPaths));

      _snack('Attendance upload started');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _snack('Failed to start upload: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Photo picking
  // -------------------------------------------------------------------------
  Future<void> _pickImage(ImageSource source) async {
    if (_photoPaths.length >= _maxPhotos) {
      _snack('Maximum $_maxPhotos photos allowed');
      return;
    }

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null || !mounted) return;
    setState(() => _photoPaths.add(image.path));
  }

  Future<void> _showImageSourcePicker() async {
    if (schedule.lectureStatus != LectureStatus.inProgress) {
      _snack('Lecture is not in progress');
      return;
    }

    if (_submitted || _isSubmitting) {
      _snack(
        _submitted ? 'Attendance already submitted' : 'Upload in progress',
      );
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
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
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

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final status = schedule.lectureStatus;
    final canAct =
        status == LectureStatus.inProgress && !_submitted && !_isSubmitting;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              'Section: ${schedule.section}',
              style: const TextStyle(color: Colors.grey),
            ),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(Icons.access_time, schedule.time),
                _InfoItem(Icons.people, '${schedule.totalStudents} students'),
                _InfoItem(Icons.location_on, schedule.room),
              ],
            ),

            const SizedBox(height: 14),

            if (widget.mode == LectureCardMode.current &&
                _photoPaths.isNotEmpty)
              _PhotoPreview(
                paths: _photoPaths,
                onRemove: canAct
                    ? (i) => setState(() => _photoPaths.removeAt(i))
                    : null,
              ),

            if (widget.mode == LectureCardMode.current)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionButton(
                    label: 'Upload photo',
                    enabled: canAct && _photoPaths.length < _maxPhotos,
                    onTap: _showImageSourcePicker,
                  ),
                  _ActionButton(
                    label: 'Report mass bunk',
                    isDanger: true,
                    enabled: canAct,
                    onTap: () => _confirm(
                      title: 'Report mass bunk',
                      message: 'Are you sure?',
                      onConfirm: _submitAttendance,
                    ),
                  ),
                  _ActionButton(
                    label: 'Mark all present',
                    enabled: canAct,
                    onTap: () => _confirm(
                      title: 'Mark all present',
                      message: 'Are you sure?',
                      onConfirm: _submitAttendance,
                    ),
                  ),
                  if (_photoPaths.isNotEmpty && !_submitted)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: canAct
                            ? () => _confirm(
                                title: 'Submit attendance',
                                message:
                                    'Once submitted, attendance cannot be changed.',
                                onConfirm: _submitAttendance,
                              )
                            : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Submit attendance'),
                      ),
                    ),
                  if (_submitted)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Attendance submitted',
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

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _PhotoPreview extends StatelessWidget {
  final List<String> paths;
  final void Function(int index)? onRemove;

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
                  if (onRemove != null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => onRemove!(i),
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
      LectureStatus.inProgress: 'In progress',
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
