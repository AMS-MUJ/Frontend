class SectionModel {
  final String name;

  SectionModel({required this.name});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(name: json['sectionName']);
  }
}
