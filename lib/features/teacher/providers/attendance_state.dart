class AttendanceState {
  final bool submitted;
  final List<String> photoPaths;

  const AttendanceState({this.submitted = false, this.photoPaths = const []});

  AttendanceState copyWith({bool? submitted, List<String>? photoPaths}) {
    return AttendanceState(
      submitted: submitted ?? this.submitted,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}
