class StateModel {
  final String name;

  StateModel({
    required this.name
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      name: json['name'] ?? '',
    );
  }
}
