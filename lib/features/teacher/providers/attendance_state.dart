class AttendanceState {
  final List<String> photoPaths;
  final bool submitting;
  final bool submitted;

  const AttendanceState({
    this.photoPaths = const [],
    this.submitting = false,
    this.submitted = false,
  });

  AttendanceState copyWith({
    List<String>? photoPaths,
    bool? submitting,
    bool? submitted,
  }) {
    return AttendanceState(
      photoPaths: photoPaths ?? this.photoPaths,
      submitting: submitting ?? this.submitting,
      submitted: submitted ?? this.submitted,
    );
  }
}
