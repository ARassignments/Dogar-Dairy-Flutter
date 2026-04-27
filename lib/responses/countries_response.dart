import '/models/country_model.dart';

class CountriesResponse {
  final List<CountryModel> countries;
  final bool error;
  CountriesResponse({required this.countries, required this.error});

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    return CountriesResponse(
      countries: (json['data'] as List<dynamic>)
          .map((e) => CountryModel.fromJson(e))
          .toList(),
      error: json['error'] ?? true,
    );
  }
}
