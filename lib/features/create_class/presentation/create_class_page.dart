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
  String? selectedBranch;
  String? selectedSubject;
  String? selectedSection;

  String classType = 'PERMANENT';

  final branches = ['CSE', 'AIML', 'IOT', 'Data Science'];
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
  TimeOfDay? selectedTime;

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
                  items: [1, 2, 3, 4],
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
                  onChanged: (v) => setState(() => selectedYear = v),
                ),

                Dropdown<String>(
                  label: 'Branch',
                  icon: Icons.layers_outlined,
                  value: selectedBranch,
                  items: branches,
                  onChanged: (v) {
                    setState(() => selectedBranch = v);
                    if (v != null && selectedYear != null) {
                      notifier.fetchSubjects(selectedYear!, v);
                    }
                  },
                ),
                Dropdown<String>(
                  label: 'Subject',
                  icon: Icons.menu_book_outlined,
                  value: selectedSubject,
                  enabled: !state.loadingSubjects && state.subjects.isNotEmpty,
                  items: state.subjects.map((s) => s.name).toList(),

                  onChanged: (v) {
                    setState(() => selectedSubject = v);
                    if (v != null && selectedBranch != null) {
                      notifier.fetchSections(v, selectedBranch!);
                    }
                  },
                ),

                Dropdown<String>(
                  label: 'Section',
                  icon: Icons.groups_outlined,
                  value: selectedSection,
                  enabled: !state.loadingSections && state.sections.isNotEmpty,
                  items: state.sections.map((s) => s.name).toList(),
                  onChanged: (v) {
                    setState(() => selectedSection = v);
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
                selectedTime = null;
              });
            },
            expandedInsets: const EdgeInsets.symmetric(horizontal: 8),
            style: ButtonStyle(
              // 🔹 background per segment
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF6C63FF); // purple-blue like image
                }
                return Colors.transparent;
              }),

              // 🔹 text + icon color
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.grey.shade700;
              }),

              // 🔹 icon color explicitly
              iconColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.grey.shade600;
              }),

              // 🔹 pill shape
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),

              // 🔹 remove borders
              side: WidgetStateProperty.all(BorderSide.none),

              // 🔹 internal padding
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

  Widget _daySelector() => Wrap(
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
        onSelected: (v) =>
            setState(() => v ? selectedDays.add(d) : selectedDays.remove(d)),

        // 🔹 COLORS
        selectedColor: const Color(0xFF6C63FF),
        // blue when selected
        backgroundColor: Colors.grey.shade200,
        // light grey when unselected
        // 🔹 REMOVE BORDER
        side: BorderSide.none,

        // 🔹 SHAPE (soft pill)
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        // 🔹 Padding for better touch & look
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      );
    }).toList(),
  );

  Widget _dateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 📅 Date selector (unchanged, card style)
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
              if (d != null) {
                setState(() => selectedDate = d);
              }
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

        // ⏰ Preset time slots
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
              onSelected: (v) {
                setState(() {
                  v ? selectedTimes.add(time) : selectedTimes.remove(time);
                });
              },

              // 🎨 Styling
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

  void _submit() {
    if (selectedYear == null ||
        selectedBranch == null ||
        selectedSubject == null ||
        selectedSection == null) {
      _snack('Please fill all academic details');
      return;
    }

    final bool isPermanent = classType == 'PERMANENT';

    final payload = {
      'year': selectedYear,
      'branch': selectedBranch,
      'courseName': selectedSubject,
      'section': selectedSection,
      if (isPermanent) 'days': selectedDays.toList(),
      if (!isPermanent) ...{
        'date': selectedDate!.toIso8601String().split('T')[0],
        'timeSlots': selectedTimes.toList(),
      },
    };

    ref
        .read(createClassNotifierProvider.notifier)
        .submitClass(isPermanent: isPermanent, payload: payload);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
