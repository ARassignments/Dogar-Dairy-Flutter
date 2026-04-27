class CitiesResponse {
  final List<String> cities;
  final bool error;
  CitiesResponse({required this.cities, required this.error});

  factory CitiesResponse.fromJson(Map<String, dynamic> json) {
    return CitiesResponse(
      cities: (json['data'] as List<dynamic>).map((e) => e.toString()).toList(),
      error: json['error'] ?? true,
    );
  }
}
