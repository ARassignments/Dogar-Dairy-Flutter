import '/models/state_model.dart';

class StatesResponse {
  final List<StateModel> states;
  final bool error;
  StatesResponse({required this.states, required this.error});

  factory StatesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return StatesResponse(
      states: (data['states'] as List<dynamic>)
          .map((e) => StateModel.fromJson(e))
          .toList(),
      error: json['error'] ?? true,
    );
  }
}
