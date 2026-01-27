import 'package:ams_try2/features/create_class/domain/entities/section_entity.dart';
import 'package:ams_try2/features/create_class/domain/entities/subject_entity.dart';

class CreateClassState {
  final bool loadingSubjects;
  final bool loadingSections;
  final bool submitting;
  final List<Subject> subjects;
  final List<Section> sections;
  final String? error;

  const CreateClassState({
    this.loadingSubjects = false,
    this.loadingSections = false,
    this.submitting = false,
    this.subjects = const [],
    this.sections = const [],
    this.error,
  });

  CreateClassState copyWith({
    bool? loadingSubjects,
    bool? loadingSections,
    bool? submitting,
    List<Subject>? subjects,
    List<Section>? sections,
    String? error,
  }) {
    return CreateClassState(
      loadingSubjects: loadingSubjects ?? this.loadingSubjects,
      loadingSections: loadingSections ?? this.loadingSections,
      submitting: submitting ?? this.submitting,
      subjects: subjects ?? this.subjects,
      sections: sections ?? this.sections,
      error: error,
    );
  }
}
