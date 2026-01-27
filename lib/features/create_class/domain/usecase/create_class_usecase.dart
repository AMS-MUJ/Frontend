import 'package:ams_try2/features/create_class/domain/repository/create_class_repository.dart';

class CreatePermanentClass {
  final CreateClassRepository repository;

  CreatePermanentClass(this.repository);

  Future<void> call(Map<String, dynamic> payload) {
    return repository.createPermanentClass(payload);
  }
}

class CreateTemporaryClass {
  final CreateClassRepository repository;
  CreateTemporaryClass(this.repository);

  Future<void> call(Map<String, dynamic> payload) {
    return repository.createTemporaryClass(payload);
  }
}
