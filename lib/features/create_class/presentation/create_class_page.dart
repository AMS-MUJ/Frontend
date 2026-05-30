import 'package:ams_try2/core/navigation/slide_page_route.dart';
import 'package:ams_try2/features/create_class/widget/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_provider.dart';

class CreateClassPage extends ConsumerStatefulWidget {
  const CreateClassPage({super.key});

  static Route<void> route() => SlidePageRoute(
    child: const CreateClassPage(),
    direction: AxisDirection.left,
  );

  @override
  ConsumerState<CreateClassPage> createState() => _CreateClassPageState();
}

class _CreateClassPageState extends ConsumerState<CreateClassPage> {
  int? selectedYear;
  String? selectedSubjectId;
  String? selectedSubjectName;
  String? selectedSectionId;
  String? selectedSectionName;
  String? selectedStartTime;

  String classType = 'PERMANENT';

  final days = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  final List<String> presetTimes = [
    '09:00',
    '09:50',
    '10:40',
    '11:30',
    '12:20',
    '13:10',
    '14:00',
    '14:50',
    '15:40',
    '16:30',
    '17:20',
  ];

  final Set<String> selectedTimes = {};
  final Set<String> selectedDays = {};
  DateTime? selectedDate;

  static const _dayMap = {
    'MON': 0,
    'TUE': 1,
    'WED': 2,
    'THU': 3,
    'FRI': 4,
    'SAT': 5,
    'SUN': 6,
  };

  String _calcEndTime(String startTime) {
    final parts = startTime.split(':');
    final startMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final endMinutes = startMinutes + 50;
    final h = (endMinutes ~/ 60).toString().padLeft(2, '0');
    final m = (endMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createClassNotifierProvider);
    final notifier = ref.read(createClassNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(title: const Text('Create Class'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Academic Details', icon: Icons.school_outlined),

          _card(
            Column(
              children: [
                Dropdown<int>(
                  label: 'Year',
                  subLabel: 'Select Year',
                  icon: Icons.event_outlined,
                  value: selectedYear,
                  items: const [1, 2, 3, 4],
                  labelBuilder: (year) {
                    switch (year) {
                      case 1:
                        return '1st Year';
                      case 2:
                        return '2nd Year';
                      case 3:
                        return '3rd Year';
                      case 4:
                        return '4th Year';
                      default:
                        return '$year Year';
                    }
                  },
                  onChanged: (v) {
                    setState(() {
                      selectedYear = v;
                      selectedSubjectId = null;
                      selectedSubjectName = null;
                      selectedSectionId = null;
                      selectedSectionName = null;
                    });
                    if (v != null) notifier.fetchSubjects(v);
                  },
                ),

                Dropdown<String>(
                  label: 'Subject',
                  icon: Icons.menu_book_outlined,
                  value: selectedSubjectName,
                  enabled: !state.loadingSubjects && state.subjects.isNotEmpty,
                  items: state.subjects.map((s) => s.name).toList(),
                  onChanged: (name) {
                    if (name == null) return;
                    final subject = state.subjects.firstWhere(
                      (s) => s.name == name,
                    );
                    setState(() {
                      selectedSubjectName = name;
                      selectedSubjectId = subject.id;
                      selectedSectionId = null;
                      selectedSectionName = null;
                    });
                    notifier.fetchSections(subject.id);
                  },
                ),

                Dropdown<String>(
                  label: 'Section',
                  icon: Icons.groups_outlined,
                  value: selectedSectionName,
                  enabled: !state.loadingSections && state.sections.isNotEmpty,
                  items: state.sections.map((s) => s.name).toList(),
                  onChanged: (name) {
                    if (name == null) return;
                    final section = state.sections.firstWhere(
                      (s) => s.name == name,
                    );
                    setState(() {
                      selectedSectionName = name;
                      selectedSectionId = section.id;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle('Class Type', icon: Icons.swap_horiz),
          _card(_classTypeSelector()),

          const SizedBox(height: 24),

          _sectionTitle('Schedule', icon: Icons.schedule),
          _card(classType == 'PERMANENT' ? _daySelector() : _dateTimePicker()),

          const SizedBox(height: 32),

          state.submitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Create Class',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
        ],
      ),
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget _sectionTitle(String text, {required IconData icon}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );

  Widget _card(Widget child) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: child,
  );

  Widget _classTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class Type', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: 'PERMANENT',
                label: Text('Permanent'),
                icon: Icon(Icons.check),
              ),
              ButtonSegment(
                value: 'TEMPORARY',
                label: Text('Temporary'),
                icon: Icon(Icons.calendar_today_outlined),
              ),
            ],
            selected: {classType},
            onSelectionChanged: (value) {
              setState(() {
                classType = value.first;
                selectedDays.clear();
                selectedDate = null;
                selectedTimes.clear();
                selectedStartTime = null;
              });
            },
            expandedInsets: const EdgeInsets.symmetric(horizontal: 8),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF6C63FF);
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.grey.shade700;
              }),
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.grey.shade600;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              side: WidgetStateProperty.all(BorderSide.none),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          classType == 'PERMANENT'
              ? 'Repeats weekly as per timetable'
              : 'One-time lecture on selected date',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _daySelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: days.map((d) {
          final isSelected = selectedDays.contains(d);
          return FilterChip(
            label: Text(
              d,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (v) => setState(
              () => v ? selectedDays.add(d) : selectedDays.remove(d),
            ),
            selectedColor: const Color(0xFF6C63FF),
            backgroundColor: Colors.grey.shade200,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );
        }).toList(),
      ),

      const SizedBox(height: 16),

      const Text(
        'Start Time',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      const SizedBox(height: 8),

      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: presetTimes.map((time) {
          final isSelected = selectedStartTime == time;
          return FilterChip(
            label: Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            selected: isSelected,
            onSelected: (v) =>
                setState(() => selectedStartTime = v ? time : null),
            selectedColor: const Color(0xFF6C63FF),
            backgroundColor: Colors.grey.shade200,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );
        }).toList(),
      ),

      if (selectedStartTime != null) ...[
        const SizedBox(height: 12),
        Text(
          'End time: ${_calcEndTime(selectedStartTime!)}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    ],
  );

  Widget _dateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDate: DateTime.now(),
              );
              if (d != null) setState(() => selectedDate = d);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : selectedDate!.toIso8601String().split('T')[0],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Select Time Slots',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presetTimes.map((time) {
            final isSelected = selectedTimes.contains(time);
            return FilterChip(
              label: Text(
                time,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (v) => setState(
                () => v ? selectedTimes.add(time) : selectedTimes.remove(time),
              ),
              selectedColor: const Color(0xFF6C63FF),
              backgroundColor: Colors.grey.shade200,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---------- SUBMIT ----------

  Future<void> _submit() async {
    if (selectedYear == null ||
        selectedSubjectId == null ||
        selectedSectionId == null) {
      _snack('Please fill all academic details');
      return;
    }

    final notifier = ref.read(createClassNotifierProvider.notifier);

    try {
      // =========================
      // PERMANENT CLASS
      // =========================
      if (classType == 'PERMANENT') {
        if (selectedDays.isEmpty) {
          _snack('Please select at least one day');
          return;
        }

        if (selectedStartTime == null) {
          _snack('Please select a start time');
          return;
        }

        final endTime = _calcEndTime(selectedStartTime!);

        for (final day in selectedDays) {
          await notifier.submitClass(
            isPermanent: true,
            payload: {
              'section_id': selectedSectionId,
              'day_of_week': _dayMap[day],
              'start_time': selectedStartTime,
              'end_time': endTime,
            },
          );

          final currentState = ref.read(createClassNotifierProvider);

          if (currentState.error != null) {
            _snack(currentState.error!);
            return;
          }
        }

        if (mounted) {
          _snack('Permanent class created successfully', isError: false);

          Navigator.pop(context);
        }

        return;
      }

      // =========================
      // TEMPORARY / EXTRA CLASS
      // =========================

      if (selectedDate == null) {
        _snack('Please select a date');
        return;
      }

      if (selectedTimes.isEmpty) {
        _snack('Please select at least one time slot');
        return;
      }

      for (final time in selectedTimes) {
        final endTime = _calcEndTime(time);

        await notifier.submitClass(
          isPermanent: false,
          payload: {
            'section_id': selectedSectionId,
            'date': selectedDate!.toIso8601String().split('T')[0],
            'start_time': time,
            'end_time': endTime,
            'is_substitute': false,
          },
        );

        final currentState = ref.read(createClassNotifierProvider);

        if (currentState.error != null) {
          _snack(currentState.error!);
          return;
        }
      }

      if (mounted) {
        _snack('Extra class created successfully', isError: false);

        Navigator.pop(context);
      }
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _snack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
