class SubjectModel {
  final String name;

  SubjectModel({required this.name});

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(name: json['name']);
  }
}
