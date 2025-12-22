import 'package:flutter/material.dart';
import '../domain/entities/schedule.dart';
import '../presentation/lecture_card_mode.dart';

class LectureCard extends StatelessWidget {
  final Schedule schedule;
  final LectureCardMode mode;

  const LectureCard({super.key, required this.schedule, required this.mode});

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
            /// 🔹 TITLE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        schedule.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

            const SizedBox(height: 4),

            Text(
              "Sections: ${schedule.section}",
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

            const SizedBox(height: 16),

            /// 🔹 ACTION BUTTONS
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    switch (mode) {
      case LectureCardMode.current:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionButton(
              label: "Mark\nAttendance",
              onTap: () => print("Mark Attendance"),
            ),
            _ActionButton(
              label: "Report\nMass Bunk",
              onTap: () => print("Report Mass Bunk"),
            ),
            _ActionButton(
              label: "Mark\nAll Present",
              onTap: () => print("Mark All Present"),
            ),
          ],
        );

      case LectureCardMode.all:
      case LectureCardMode.upcoming:
        return Align(
          alignment: Alignment.center,
          child: _ActionButton(
            label: "Cancel Lecture",
            isDanger: true,
            onTap: () => print("Cancel Lecture"),
          ),
        );
    }
  }
}

/// 🔹 Status text shown at top-right
class _StatusText extends StatelessWidget {
  final LectureStatus status;

  const _StatusText(this.status);

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;

    switch (status) {
      case LectureStatus.inProgress:
        text = 'In Progress';
        color = Colors.green;
        break;

      case LectureStatus.pending:
        text = 'Pending';
        color = Colors.black;
        break;

      case LectureStatus.completed:
        text = 'Completed';
        color = Colors.black;
        break;
    }

    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }
}

/// 🔹 Small info widget
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

/// 🔹 Action button widget
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
