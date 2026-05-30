class SectionModel {
  final String id;
  final String name;

  SectionModel({required this.id, required this.name});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['section_id'], // matches API response key
      name: json['section_name'],
    );
  }
}
