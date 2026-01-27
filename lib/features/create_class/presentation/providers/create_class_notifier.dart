import 'package:ams_try2/features/create_class/domain/usecase/create_class_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_sections_usecase.dart';
import 'package:ams_try2/features/create_class/domain/usecase/get_subjects_usecase.dart';
import 'package:ams_try2/features/create_class/presentation/providers/create_class_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateClassNotifier extends StateNotifier<CreateClassState> {
  final GetSubjects getSubjects;
  final GetSections getSections;
  final CreatePermanentClass createPermanentClass;
  final CreateTemporaryClass createTemporaryClass;

  CreateClassNotifier(
    this.getSubjects,
    this.getSections,
    this.createPermanentClass,
    this.createTemporaryClass,
  ) : super(const CreateClassState());

  Future<void> fetchSubjects(int year, String branch) async {
    state = state.copyWith(
      loadingSubjects: true,
      subjects: [],
      sections: [],
      error: null,
    );

    try {
      final data = await getSubjects(year, branch);
      state = state.copyWith(subjects: data, loadingSubjects: false);
    } catch (e) {
      state = state.copyWith(loadingSubjects: false, error: e.toString());
    }
  }

  Future<void> fetchSections(String subject, String branch) async {
    state = state.copyWith(loadingSections: true, sections: [], error: null);

    try {
      final data = await getSections(subject, branch);
      state = state.copyWith(sections: data, loadingSections: false);
    } catch (e) {
      state = state.copyWith(loadingSections: false, error: e.toString());
    }
  }

  Future<void> submitClass({
    required bool isPermanent,
    required Map<String, dynamic> payload,
  }) async {
    state = state.copyWith(submitting: true, error: null);

    try {
      if (isPermanent) {
        await createPermanentClass(payload);
      } else {
        await createTemporaryClass(payload);
      }

      state = state.copyWith(submitting: false);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
    }
  }
}
